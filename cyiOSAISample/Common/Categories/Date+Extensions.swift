//
//  Date+Extensions.swift
//  cyiOSAISample
//
//  Created by Michael on 30/03/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
