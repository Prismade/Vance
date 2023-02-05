//
//  YouTubeWebPage.swift
//  Vance
//
//  Created by Egor Molchanov on 15.01.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import Foundation

class YouTubeWebPage {
    let videoID: String
    var html: String?
    
    private(set) var isLoaded = false
    private let re = RegexUtil()
    private var pageURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "youtube.com"
        components.path = "/watch"
        components.queryItems = [
            URLQueryItem(name: "v", value: videoID),
            URLQueryItem(name: "bpctr", value: "9999999999"),
            URLQueryItem(name: "has_verified", value: "1")
        ]
        return components.url
    }
    
    init(videoID: String) {
        self.videoID = videoID
    }
    
    init?(videoURL: URL) {
        guard let videoID = re.matchID(from: videoURL) else { return nil }
        self.videoID = videoID
    }
    
    init?(videoURLString: String) {
        guard let videoID = re.matchID(from: videoURLString) else { return nil }
        self.videoID = videoID
    }
    
    func load() async throws -> String? {
        guard !isLoaded else { return html }
        guard let url = pageURL else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        html = String(data: data, encoding: .utf8)
        return html
    }
}
