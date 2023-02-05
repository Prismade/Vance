//
//  InnertubeClient.swift
//  Vance
//
//  Created by Egor Molchanov on 15.01.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import Foundation

struct InnertubeClient {
    struct ClientContext {
        let name: String
        let version: String
        let model: String?
        let userAgent: String?
    }
    let apiKey: String?
    let context: ClientContext
    let contextClientName: String
    let isJSPlayerRequired: Bool
}

extension InnertubeClient {
    static let webClient = InnertubeClient(
        apiKey: "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8",
        context: ClientContext(
            name: "WEB",
            version: "2.20220801.00.00",
            model: nil,
            userAgent: nil
        ),
        contextClientName: "1",
        isJSPlayerRequired: false)
    static let iOSClient = InnertubeClient(
        apiKey: "AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc",
        context: ClientContext(
            name: "IOS",
            version: "17.33.2",
            model: "iPhone14,3",
            userAgent: "com.google.ios.youtube/17.33.2 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)"
        ),
        contextClientName: "5",
        isJSPlayerRequired: false)
    static let iOSEmbeddedClient = InnertubeClient(
        apiKey: nil,
        context: ClientContext(
            name: "IOS_MESSAGES_EXTENSION",
            version: "17.33.2",
            model: "iPhone14,3",
            userAgent: "com.google.ios.youtube/17.33.2 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)"
        ),
        contextClientName: "66",
        isJSPlayerRequired: false)
    static let iOSMusicClient = InnertubeClient(
        apiKey: "AIzaSyBAETezhkwP0ZWA02RsqT1zu78Fpt0bC_s",
        context: ClientContext(
            name: "IOS_MUSIC",
            version: "5.21",
            model: "iPhone14,3",
            userAgent: "com.google.ios.youtubemusic/5.21 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)"
        ),
        contextClientName: "26",
        isJSPlayerRequired: false)
    static let iOSCreatorClient = InnertubeClient(
        apiKey: nil,
        context: ClientContext(
            name: "IOS_CREATOR",
            version: "22.33.101",
            model: "iPhone14,3",
            userAgent: "com.google.ios.ytcreator/22.33.101 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)"
        ),
        contextClientName: "15",
        isJSPlayerRequired: false)
}
