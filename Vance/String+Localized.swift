//
//  String+Localized.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
