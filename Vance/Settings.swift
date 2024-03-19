//
//  Settings.swift
//  Vance
//
//  Created by Egor Molchanov on 19.03.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import Foundation

struct Settings {
  @BoolSetting(key: "queue-enabled")
  static var isQueueEnabled

  @BoolSetting(key: "custom-player-enabled")
  static var isCustomPlayerEnabled
}
