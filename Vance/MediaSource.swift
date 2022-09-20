//
//  MediaSource.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import Foundation

struct MediaSource {
    static func mediaUrl(for youtubePageUrl: URL) async throws -> URL {
        guard YouTubePageUrlValidator.validate(url: youtubePageUrl) else {
            throw VanceError.wrongYouTubePageUrlFormat
        }
        
        let html = try await YouTubePageLoader.load(from: youtubePageUrl)
        
        if let mediaUrl = MediaUrlExtractor.extractM3U8MediaPlaylistUrl(from: html) {
            return mediaUrl
        }
        
        if let urls = MediaUrlExtractor.extractMediaUrls(from: html),
           let mediaUrl = urls["format_medium"] ?? urls["adaptiveFormat_360p"] {
            return mediaUrl
        }
        
        throw VanceError.mediaNotFound
    }
}
