//
//  Settings.swift
//  Vance
//
//  Created by Egor Molchanov on 19.03.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import Foundation

struct Settings {
  static let kQueueEnabled = "queue-enabled"
  static let kCustomPlayerEnabled = "custom-player-enabled"

  static var isQueueEnabled: Bool {
    get {
      UserDefaults.standard.bool(forKey: kQueueEnabled)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: kQueueEnabled)
    }
  }
  static var isCustomPlayerEnabled: Bool {
    get {
      UserDefaults.standard.bool(forKey: kCustomPlayerEnabled)
    }
    set {
      UserDefaults.standard.setValue(newValue, forKey: kCustomPlayerEnabled)
    }
  }
}
