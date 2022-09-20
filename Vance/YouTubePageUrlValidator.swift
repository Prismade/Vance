//
//  YouTubePageUrlValidator.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import Foundation

struct YouTubePageUrlValidator {
    static let prefixes = ["https://youtu.be/", "https://youtube.com/watch"]
    
    static func validate(url: URL) -> Bool {
        return validate(urlString: url.absoluteString)
    }
    
    static func validate(urlString: String) -> Bool {
        return prefixes.reduce(into: false) { partialResult, `prefix` in
            partialResult = partialResult || urlString.hasPrefix(`prefix`)
        }
    }
}
