//
//  Notification+Name.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var urlIsAvailableFromPasteboard: Self {
        return .init("UrlIsAvailableFromPasteboard")
    }
    static var urlIsUnavailableFromPasteboard: Self {
        return .init("UrlIsUnavailableFromPasteboard")
    }
}
