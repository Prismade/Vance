//
//  Errors.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import Foundation

enum VanceError: LocalizedError {
    case wrongUrl
    case emptyResponse
    case wrongYouTubePageUrlFormat
    case mediaNotFound
    case other(message: String)
    
    var errorDescription: String? {
        switch self {
        case .wrongUrl:
            return "Unable to create URL from provided string"
        case .emptyResponse:
            return "Failed to create NSString from data because it was empty"
        case .wrongYouTubePageUrlFormat:
            return "The YouTube Page URL format is not one of supported formats"
        case .mediaNotFound:
            return "Media URLs not found in YouTube page source"
        case .other(message: let message):
            return message
        }
    }
}
