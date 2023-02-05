//
//  RegexUtil.swift
//  Vance
//
//  Created by Egor Molchanov on 08.01.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import Foundation

fileprivate let validURLPattern = #"(?:https:\/\/|https:\/\/www\.)(?:youtu\.be\/|youtube\.com\/(?:watch\?v=|live\/))(?<id>[0-9A-Za-z_-]{11})"#

struct RegexUtil {
    func matchID(from url: URL) -> String? {
        let urlString = url.absoluteString
        return matchID(from: urlString)
    }
    
    func matchID(from urlString: String) -> String? {
        guard let match = matchValidURL(urlString) else { return nil }
        let nsrange = match.range(withName: "id")
        
        if nsrange.location != NSNotFound, let range = Range(nsrange, in: urlString) {
            return String(urlString[range])
        }
        return nil
    }
    
    func matchValidURL(_ urlString: String) -> NSTextCheckingResult? {
        do {
            let regex = try NSRegularExpression(pattern: validURLPattern)
            let range = NSRange(urlString.startIndex..<urlString.endIndex, in: urlString)
            return regex.firstMatch(in: urlString, range: range)
        } catch {
            print(error)
            return nil
        }
    }
    
    func matchJSON(startPattern: String, string: String, endPattern: String = "", containsPattern: String = #"\{(?:.+)\}"#) -> String? {
        let pattern = #"(?:\#(startPattern))(?<json>\#(containsPattern))(?:\#(endPattern))"#
        return searchRegex(pattern: pattern, string: string, group: "json")
    }
    
    func searchRegex(pattern: String, string: String, group: String?) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsrange = NSRange(string.startIndex..<string.endIndex, in: string)
        guard let match = regex?.firstMatch(in: string, range: nsrange) else { return nil }
        
        if let group {
            let nsrange = match.range(withName: group)
            guard nsrange.location != NSNotFound, let range = Range(nsrange, in: string) else { return nil }
            return String(string[range])
        } else {
            guard let range = Range(match.range(at: 1), in: string) else { return nil }
            return String(string[range])
        }
    }
}
