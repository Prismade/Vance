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
    let url: URL
    let headers: [String: String]
    let title: String?
    let description: String?
    let author: String?
    let thumbnail: String?
    let viewCount: String?
}
