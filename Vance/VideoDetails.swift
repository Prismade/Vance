//
//  VideoDetails.swift
//  Vance
//
//  Created by Egor Molchanov on 05.02.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import Foundation

struct VideoThumbnail {
    let url: URL
    let size: CGSize
}

struct VideoDetails {
    let isLiveStream: Bool
    let urls: [String: URL]
    let title: String?
    let description: String?
    let author: String?
    let thumbnails: [VideoThumbnail]?
    let viewCount: String?
}
