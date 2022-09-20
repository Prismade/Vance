//
//  MediaUrlExtractor.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import Foundation

struct MediaUrlExtractor {
    static func extractMediaUrls(from html: String) -> [String: URL]? {
        guard
            let jsonObject = extractJsonWithMediaUrls(from: html),
            let formatsUrls = extractMediaUrls(formatsJson: jsonObject),
            let adaptiveFormatsUrls = extractMediaUrls(adaptiveFormatsJson: jsonObject)
        else {
            return nil
        }
        
        return formatsUrls.merging(adaptiveFormatsUrls) { current, _ in current }
    }
    
    static func extractM3U8MediaPlaylistUrl(from html: String) -> URL? {
        guard let startRange = html.range(of: "\"hlsManifestUrl\":\"") else { return nil }
        
        let almostUrlSubstring = html[startRange.upperBound...]
        
        guard let endRange = almostUrlSubstring.range(of: "\"") else { return nil }
        
        let urlString = almostUrlSubstring[almostUrlSubstring.startIndex..<endRange.lowerBound]
        let url = URL(string: String(urlString))
        return url
    }
    
    private static func extractJsonWithMediaUrls(from html: String) -> [String: Any]? {
        guard let startRange = html.range(of: "var ytInitialPlayerResponse = {") else { return nil }
        
        let startIndex = String.Index(utf16Offset: startRange.upperBound.utf16Offset(in: html) - 1, in: html)
        
        let almostJsonSubstring = html[startIndex...]
        
        guard let endRange = almostJsonSubstring.range(of: ";</script>") else { return nil }
        
        let jsonString = almostJsonSubstring[almostJsonSubstring.startIndex..<endRange.lowerBound]
        
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData)
        return jsonObject as? [String: Any]
    }
    
    private static func extractMediaUrls(formatsJson: [String: Any]) -> [String: URL]? {
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
    
    private static func extractMediaUrls(adaptiveFormatsJson: [String: Any]) -> [String: URL]? {
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
}
