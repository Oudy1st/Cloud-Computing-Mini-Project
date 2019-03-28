//
//  Codable.swift
//  SinghaSaleVisit
//
//  Created by Detchat Boonpragob on 26/3/2561 BE.
//  Copyright © 2561 Zoso. All rights reserved.
//

import Foundation

extension Encodable {
    
    var dictionaryArray: [[String: Any]]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [[String: Any]] }
    }
    
//    var dictionaryArray: Any? {
//        guard let data = try? JSONEncoder().encode(self) else { return nil }
//        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
//    }
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    var isDictionaryable : Bool {
        guard let data = try? JSONEncoder().encode(self) else { return false }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) != nil
    }
    
    func copy<T:Codable>() -> T? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

extension Dictionary {
    func toPostDataString() -> String {
        if self.keys.count > 0 {
            let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
            return  Array(self.keys.map({ "\($0)=\(String(describing: String(describing:self[$0]!).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!))"})).joined(separator: "&")
            
        }
        else
        {
            return ""
        }
    }
    func toGetDataString() -> String {
        if self.keys.count > 0 {
            let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
            return  Array(self.keys.map({ "\($0)=\(String(describing: String(describing:self[$0]!).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!))"})).joined(separator: "&")
            
        }
        else
        {
            return ""
        }
    }
    func toJsonString() -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted) {
            return String(data: jsonData, encoding: .utf8)!
        }
        else
        {
            return ""
        }
    }
}

extension Array {
    func toJsonString() -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted) {
            return String(data: jsonData, encoding: .utf8)!
        }
        else
        {
            return ""
        }
    }
}
