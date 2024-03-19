//
//  Settings.swift
//  Vance
//
//  Created by Egor Molchanov on 19.03.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import Foundation

enum Settings {
  @Toggle(key: "queue-enabled")
  static var isQueueEnabled

  @Toggle(key: "custom-player-enabled")
  static var isCustomPlayerEnabled
}
