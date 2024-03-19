//
//  Int+Format.swift
//  Vance
//
//  Created by Egor Molchanov on 13.02.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import Foundation

extension Int {
  // source: https://stackoverflow.com/a/23290016
  var formattedUsingAbbrevation: String {
    if self < 1000 {
      return String(self)
    }

    let units = [
      NSLocalizedString("ShortForThousands", comment: ""),
      NSLocalizedString("ShortForMillions", comment: ""),
      NSLocalizedString("ShortForBillions", comment: "")
    ]

    let exp = Int(log10(Double(self)) / 3.0)

    let roundedNum = Int(round(10.0 * Double(self) / pow(1000.0, Double(exp))) / 10)
    return "\(roundedNum)\(units[exp - 1])"
  }
}
