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

  func extractInfo(from url: String) throws -> Video? {
    let ytdlpModule = Python.import("yt_dlp")
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
      let infoJSONObject = try? ytdlp.sanitize_info.throwing.dynamicallyCall(withArguments: info),
      let jsonStringObject = try? jsonModule.dumps.throwing.dynamicallyCall(withArguments: infoJSONObject),
      let jsonString = String(jsonStringObject),
      let jsonData = jsonString.data(using: .utf8),
      let infoJSON = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
    else {
      return nil
    }

    let video = Video(
      url: infoJSON.firstValue(for: ["url"]) as? String,
      headers: infoJSON.firstValue(for: ["http_headers"]) as? [String: String],
      title: infoJSON.firstValue(for: ["fulltitle"]) as? String,
      description: infoJSON.firstValue(for: ["description"]) as? String,
      isLive: infoJSON.firstValue(for: ["is_live"]) as? Bool,
      wasLive: infoJSON.firstValue(for: ["was_live"]) as? Bool,
      liveStatus: infoJSON.firstValue(for: ["live_status"]) as? String,
      tags: infoJSON.firstValue(for: ["tags"]) as? [String],
      categories: infoJSON.firstValue(for: ["categories"]) as? [String],
      commentsCount: infoJSON.firstValue(for: ["comment_count"]) as? Int,
      viewsCount: infoJSON.firstValue(for: ["view_count"]) as? Int,
      thumbnailURL: infoJSON.firstValue(for: ["thumbnail"]) as? String,
      uploadDate: infoJSON.firstValue(for: ["upload_date"]) as? String,
      aspectRatio: infoJSON.firstValue(for: ["aspect_ratio"]) as? Double,
      width: infoJSON.firstValue(for: ["width"]) as? Int,
      height: infoJSON.firstValue(for: ["height"]) as? Int,
      duration: infoJSON.firstValue(for: ["duration"]) as? Int,
      availability: infoJSON.firstValue(for: ["availability"]) as? String,
      channelIdentifier: infoJSON.firstValue(for: ["channel_id"]) as? String,
      channelURL: infoJSON.firstValue(for: ["channel_url"]) as? String,
      channelName: infoJSON.firstValue(for: ["channel"]) as? String,
      channelFollowersCount: infoJSON.firstValue(for: ["channel_follower_count"]) as? Int,
      channelIsVerified: infoJSON.firstValue(for: ["channel_is_verified"]) as? Bool,
      json: infoJSON
    )

    return video
  }
}
