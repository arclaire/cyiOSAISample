//
//  SQLogger.swift
//  MyCurrency
//
//  Created by Lucy on 18/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//

import Foundation
enum LogType: Int {
    case kTrace = 1 //Default black
    case kDebug = 2
    case kInfo = 3
    case kWarning = 4
    case kError = 5
    case kImportant = 6
    case kVeryImportant = 7
    case kNetworkRequest = 8
    case kNetworkResponseSuccess = 9
    case kNetworkResponseError = 10
}

enum PrintColors: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    
    func name() -> String {
        switch self {
        case .black: return "Black"
        case .red: return "Red"
        case .green: return "Green"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        case .magenta: return "Magenta"
        case .cyan: return "Cyan"
        case .white: return "White"
        }
    }
}

class SQLogger {
    var isLogEnabled: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    class var sharedLogger: SQLogger {
        struct defaultSingleton {
            static let loggerInstance = SQLogger()
        }
        return defaultSingleton.loggerInstance
    }
    
    class func log(_ logString: Any, logType: LogType? = .kTrace, isColorEnabled: Bool? = false) {
        if (SQLogger.sharedLogger.isLogEnabled == false && logType != .kImportant) {
            return
        } else {
            switch logType {
            case .kDebug?:
                print("SQ: \(isColorEnabled! ? PrintColors.magenta.rawValue : "")\(logString)")
            case .kInfo?:
                print("SQ: \(isColorEnabled! ? PrintColors.green.rawValue : "")\(logString)")
            case .kWarning?:
                print("SQ: \(isColorEnabled! ? PrintColors.blue.rawValue : "")\(logString)")
            case .kError?:
                print("SQ: \(isColorEnabled! ? PrintColors.red.rawValue : "")\(logString)")
            case .kImportant?:
                print("SQ: \(isColorEnabled! ? PrintColors.black.rawValue : "")\(logString)")
            case .kNetworkRequest?:
                print("SQ-NETWORK-REQUEST: \(Date.init()) \(isColorEnabled! ? PrintColors.black.rawValue : "📔:")\(logString)")
            case .kNetworkResponseSuccess?:
                print("SQ-NETWORK-RESPONSE: \(Date.init()) \(isColorEnabled! ? PrintColors.black.rawValue : "📗:")\(logString)")
            case .kNetworkResponseError?:
                print("SQ-NETWORK-ERROR: \(Date.init()) \(isColorEnabled! ? PrintColors.black.rawValue : "🛑:")\(logString)")
            default:
                print("SQ: \(isColorEnabled! ? PrintColors.black.rawValue : "")\(logString)")
            }
        }
    }
}
