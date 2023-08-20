//
//  NSDictionary+Extension.swift
//  cyiOSAISample
//
//  Created by Michael on 30/03/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}
