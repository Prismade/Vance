//
//  Dictionary+Convenience.swift
//  Vance
//
//  Created by Egor Molchanov on 17.01.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import Foundation

extension Dictionary {
    func firstValue(for keys: [AnyHashable]) -> Any? {
        var queue: [Any] = [self]
        
        while !queue.isEmpty {
            let element = queue.removeFirst()
            
            if let dictionary = element as? [AnyHashable: Any] {
                let dictionaryKeys = dictionary.keys.map { $0 }
                for k in dictionaryKeys {
                    guard !keys.contains(k) else { return dictionary[k] }
                    if let childDictionary = dictionary[k] as? [AnyHashable: Any] {
                        queue.append(childDictionary)
                    } else if let array = dictionary[k] as? [Any] {
                        queue.append(array)
                    }
                }
            } else if let array = element as? [Any] {
                for v in array {
                    if let dictionary = v as? [AnyHashable: Any] {
                        queue.append(dictionary)
                    } else if let childArray = v as? [Any] {
                        queue.append(childArray)
                    }
                }
            }
        }
        return nil
    }
}
