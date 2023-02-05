//
//  YouTubeInfoExtractor.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import Foundation

struct YouTubeInfoExtractor {
    let re = RegexUtil()
    
    func extractInfo(from html: String) -> VideoDetails? {
        guard let jsonObject = extractPlayerResponse(from: html) else { return nil }
        
        var formats: [String: URL]
        
        if
            let formatsUrls = extractMediaUrls(formatsJson: jsonObject),
            let adaptiveFormatsUrls = extractMediaUrls(adaptiveFormatsJson: jsonObject)
        {
            formats = formatsUrls.merging(adaptiveFormatsUrls) { current, _ in current }
        } else if let playlistURL = extractM3U8MediaPlaylistUrl(from: html) {
            formats = ["livestream": playlistURL]
        } else {
            formats = [:]
        }
        
        return extractVideoDetails(from: jsonObject, adding: formats)
    }
    
    func extractM3U8MediaPlaylistUrl(from html: String) -> URL? {
        guard let startRange = html.range(of: "\"hlsManifestUrl\":\"") else { return nil }
        
        let almostUrlSubstring = html[startRange.upperBound...]
        
        guard let endRange = almostUrlSubstring.range(of: "\"") else { return nil }
        
        let urlString = almostUrlSubstring[almostUrlSubstring.startIndex..<endRange.lowerBound]
        let url = URL(string: String(urlString))
        return url
    }
    
    func extractPlayerResponse(from html: String) -> [String: Any]? {
        guard
            let jsonString = re.matchJSON(startPattern: #"ytInitialPlayerResponse\s=\s"#, string: html, endPattern: #";</script>"#),
            let jsonData = jsonString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            return nil
        }
        return jsonObject
    }
    
    func extractYTCFG(from html: String) -> [String: Any] {
        guard
            let jsonString = re.matchJSON(startPattern: #"ytcfg\.set\("#, string: html, endPattern: #"\);"#),
            let jsonData = jsonString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            return [:]
        }
        return jsonObject
    }
    
    func extractMediaUrls(formatsJson: [String: Any]) -> [String: URL]? {
        var mediaUrls = [String: URL]()
        guard let adaptiveFormats = (formatsJson["streamingData"] as? [String: Any])?["formats"] as? [[String: Any]] else {
            return nil
        }
        for format in adaptiveFormats {
            guard (format["mimeType"] as? String)?.hasPrefix("video/mp4") ?? false else { continue }
            let key = "format_\(format["quality"] as? String ?? "")"
            let object = URL(string: format["url"] as? String ?? "")
            
            guard let object = object else { continue }
            mediaUrls[key] = object
        }
        return mediaUrls
    }
    
    func extractMediaUrls(adaptiveFormatsJson: [String: Any]) -> [String: URL]? {
        var mediaUrls = [String: URL]()
        guard let adaptiveFormats = (adaptiveFormatsJson["streamingData"] as? [String: Any])?["adaptiveFormats"] as? [[String: Any]] else {
            return nil
        }
        for format in adaptiveFormats {
            guard (format["mimeType"] as? String)?.hasPrefix("video/mp4") ?? false else { continue }
            let key = "adaptiveFormat_\(format["qualityLabel"] as? String ?? "")"
            let object = URL(string: format["url"] as? String ?? "")
            
            guard let object = object else { continue }
            mediaUrls[key] = object
        }
        return mediaUrls
    }
    
    func extractVideoDetails(from json: [String: Any], adding formats: [String: URL]) -> VideoDetails? {
        guard
            let details = json["videoDetails"] as? [String: Any]
        else {
            return nil
        }
        
        let thumbnails: [VideoThumbnail]? = (details["thumbnail"] as? [String: [[String: Any]]])?["thumbnails"]?.compactMap { data in
            guard
                let urlString = data["url"] as? String,
                let url = URL(string: urlString),
                let width = data["width"] as? CGFloat,
                let height = data["height"] as? CGFloat
            else {
                return nil
            }
            return VideoThumbnail(url: url, size: CGSize(width: width, height: height))
        }
        
        return VideoDetails(
            isLiveStream: formats["livestream"] != nil,
            urls: formats,
            title: details["title"] as? String,
            description: details["shortDescription"] as? String,
            author: details["author"] as? String,
            thumbnails: thumbnails,
            viewCount: details["viewCount"] as? String)
        
    }
}
