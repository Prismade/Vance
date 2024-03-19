//
//  Video.swift
//  Vance
//
//  Created by Egor Molchanov on 05.02.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import Foundation

final class Info {
  let title: String?
  let description: String?
  let isLive: Bool
  let wasLive: Bool
  let liveStatus: String?
  let tags: [String]?
  let categories: [String]?
  let commentsCount: Int?
  let viewsCount: Int?
  let thumbnailURL: URL?
  let uploadDate: String?

  init(title: String? = nil, description: String? = nil, isLive: Bool? = nil, wasLive: Bool? = nil, liveStatus: String? = nil, tags: [String]? = nil, categories: [String]? = nil, commentsCount: Int? = nil, viewsCount: Int? = nil, thumbnailURL: String? = nil, uploadDate: String? = nil) {
    self.title = title
    self.description = description
    self.isLive = isLive ?? false
    self.wasLive = wasLive ?? false
    self.liveStatus = liveStatus
    self.tags = tags
    self.categories = categories
    self.commentsCount = commentsCount
    self.viewsCount = viewsCount
    self.thumbnailURL = if let thumbnailURL {
      URL(string: thumbnailURL)
    } else {
      nil
    }
    self.uploadDate = uploadDate
  }
}

final class Metadata {
  let aspectRatio: Double?
  let size: CGSize?
  let duration: Int?
  let availability: String?

  init(aspectRatio: Double? = nil, width: Int? = nil, height: Int? = nil, duration: Int? = nil, availability: String? = nil) {
    self.aspectRatio = aspectRatio
    self.size = if let width, let height {
      CGSize(width: CGFloat(width), height: CGFloat(height))
    } else {
      nil
    }
    self.duration = duration
    self.availability = availability
  }
}

final class Channel {
  let identifier: String?
  let url: URL?
  let name: String?
  let followersCount: Int?
  let isVerifies: Bool

  init(identifier: String? = nil, url: String? = nil, name: String? = nil, followersCount: Int? = nil, isVerified: Bool? = nil) {
    self.identifier = identifier
    self.url = if let url {
      URL(string: url)
    } else {
      nil
    }
    self.name = name
    self.followersCount = followersCount
    self.isVerifies = isVerified ?? false
  }
}

final class Video {
  let url: URL?
  let headers: [String: String]?
  let info: Info
  let meta: Metadata
  let channel: Channel
  let json: [String: Any]

  init(url: String? = nil, headers: [String: String]? = nil, title: String? = nil, description: String? = nil, isLive: Bool? = nil, wasLive: Bool? = nil, liveStatus: String? = nil, tags: [String]? = nil, categories: [String]? = nil, commentsCount: Int? = nil, viewsCount: Int? = nil, thumbnailURL: String? = nil, uploadDate: String? = nil, aspectRatio: Double? = nil, width: Int? = nil, height: Int? = nil, duration: Int? = nil, availability: String? = nil, channelIdentifier: String? = nil, channelURL: String? = nil, channelName: String? = nil, channelFollowersCount: Int? = nil, channelIsVerified: Bool? = nil, json: [String: Any]) {
    self.url = if let url {
      URL(string: url)
    } else {
      nil
    }
    self.headers = headers
    self.info = Info(
      title: title,
      description: description,
      isLive: isLive,
      wasLive: wasLive,
      liveStatus: liveStatus,
      tags: tags,
      categories: categories,
      commentsCount: commentsCount,
      viewsCount: viewsCount,
      thumbnailURL: thumbnailURL,
      uploadDate: uploadDate
    )
    self.meta = Metadata(
      aspectRatio: aspectRatio,
      width: width,
      height: height,
      duration: duration,
      availability: availability
    )
    self.channel = Channel(
      identifier: channelIdentifier,
      url: channelURL,
      name: channelName,
      followersCount: channelFollowersCount,
      isVerified: channelIsVerified
    )
    self.json = json
  }
}

extension Video: Equatable {
  static func == (lhs: Video, rhs: Video) -> Bool {
    return lhs.url == rhs.url
  }
}
