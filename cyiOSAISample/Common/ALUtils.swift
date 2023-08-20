//
//  ALUtils.swift
//  cyiOSAISample
//
//  Created by Lucy on 12/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation
struct ALUtils {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    static func alert(_ title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                   style: .default, handler: nil)
        alertController.addAction(action)
        return alertController
    }
}

extension ALUtils {
    static func getAppVersion() -> String {
        if let dictionary = Bundle.main.infoDictionary {
            if let version = dictionary["CFBundleShortVersionString"] as? String {
                return version
            }
        }
        return ""
    }
}
