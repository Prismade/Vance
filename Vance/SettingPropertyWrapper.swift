//
//  SettingPropertyWrapper.swift
//  Vance
//
//  Created by Egor Molchanov on 19.03.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import Foundation

@propertyWrapper struct BoolSetting {
  let key: String
  var defaults: UserDefaults = .standard

  var wrappedValue: Bool {
    get {
      defaults.bool(forKey: key)
    }
    set {
      defaults.setValue(newValue, forKey: key)
    }
  }
}
