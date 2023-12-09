//
//  Video.swift
//  Vance
//
//  Created by Egor Molchanov on 05.02.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import Foundation

final class Video {
  let url: URL
  let headers: [String: String]
  let title: String?
  let description: String?
  let author: String?
  let thumbnailURL: URL?
  var thumbnailData: Data?
  let viewCount: String?
  
  init(url: URL, headers: [String : String], title: String?, description: String?, author: String?, thumbnailURL: URL?, thumbnailData: Data? = nil, viewCount: String?) {
    self.url = url
    self.headers = headers
    self.title = title
    self.description = description
    self.author = author
    self.thumbnailURL = thumbnailURL
    self.thumbnailData = thumbnailData
    self.viewCount = viewCount
  }
  
  func downloadThumbnail() async {
    guard let thumbnailURL else { return }
    do {
      let (data, _) = try await URLSession.shared.data(from: thumbnailURL)
      thumbnailData = data
    } catch {
    }
  }
}

extension Video: Equatable {
  static func == (lhs: Video, rhs: Video) -> Bool {
    return lhs.url == rhs.url
  }
}
