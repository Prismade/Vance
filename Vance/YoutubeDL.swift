//
//  YoutubeDL.swift
//  Vance
//
//  Created by Egor Molchanov on 10.03.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import Foundation
import Python
import PythonKit

final class YoutubeDL {
    private let applicationSupportDirectoryURL: URL
    private let pipPackagePathURL: URL
    
    init?() {
        do {
            self.applicationSupportDirectoryURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            if !FileManager.default.fileExists(atPath: self.applicationSupportDirectoryURL.path) {
                try FileManager.default.createDirectory(at: self.applicationSupportDirectoryURL, withIntermediateDirectories: false)
            }
            self.pipPackagePathURL = self.applicationSupportDirectoryURL.appendingPathComponent("yt_dlp", conformingTo: .url)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Main methods
    
    func extractInfo(from url: String) throws -> VideoDetails? {
        let ytdlpModule = Python.import("yt-dlp")
        let jsonModule = Python.import("json")
        
        let options: PythonObject = [
            "nocheckcertificate": true,
            "format": "(mp4)[height<=720][acodec!=none]",
            "verbose": true
        ]
        
        let ytdlp = ytdlpModule.YoutubeDL(options)
        let info: PythonObject = try ytdlp.extract_info
            .throwing
            .dynamicallyCall(
                withKeywordArguments: [
                    "": url,
                    "download": false,
                    "process": true])
        let formatSelector = ytdlp.build_format_selector(options["format"])
        let selectedFormats = formatSelector(info)
        var formats: [[String: PythonObject]] = []
        for format in selectedFormats {
            guard let dict: [String: PythonObject] = Dictionary(format) else { fatalError() }
            formats.append(dict)
        }
        guard
            let firstFormat = formats.first,
            let urlString = String(firstFormat["url"]!),
            let url = URL(string: urlString),
            let headers: [String: String] = Dictionary(firstFormat["http_headers"]!)
        else {
            return nil
        }
        
        var title: String?
        var description: String?
        var author: String?
        var thumbnail: String?
        var viewCount: String?
        
        if
            let infoJSONObject = try? ytdlp.sanitize_info.throwing.dynamicallyCall(withArguments: info),
            let jsonStringObject = try? jsonModule.dumps.throwing.dynamicallyCall(withArguments: infoJSONObject),
            let jsonString = String(jsonStringObject),
            let jsonData = jsonString.data(using: .utf8),
            let infoJSON = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        {
            title = infoJSON.firstValue(for: ["fulltitle"]) as? String
            description = infoJSON.firstValue(for: ["description"]) as? String
            author = infoJSON.firstValue(for: ["channel"]) as? String
            if let viewCountNumber = infoJSON.firstValue(for: ["view_count"]) as? Int {
                viewCount = String(viewCountNumber)
            }
            thumbnail = infoJSON.firstValue(for: ["thumbnail"]) as? String
        }
        
        let details = VideoDetails(
            url: url,
            headers: headers,
            title: title,
            description: description,
            author: author,
            thumbnailURL: URL(string: thumbnail ?? ""),
            thumbnailData: nil,
            viewCount: viewCount)
        
        return details
    }
}
