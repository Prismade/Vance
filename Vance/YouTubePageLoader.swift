//
//  YouTubePageLoader.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import Foundation

struct YouTubePageLoader {
    static func load(from url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw VanceError.other(message: "Unable to create string with html from response data")
        }
        return html
    }
}
