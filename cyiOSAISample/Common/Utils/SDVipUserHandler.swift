//
//  SDVipUserHandler.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/30.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

@objc protocol SDVipUserHandler: NSObjectProtocol {
    func onPurchased(_ notification: NSNotification)
    
    func onRestore(_ notification: NSNotification)
}

extension SDVipUserHandler {
    func observePurchaseSuccessNotification() {
        //NotificationCenter.default.addObserver(self, selector: #selector(onPurchased(_:)), name:  Notification.Name.purchaseSuccess, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(onRestore(_:)), name:  Notification.Name.restoreSuccess, object: nil)
    }
    
    func removePurchaseSuccessNotification() {
        NotificationCenter.default.removeObserver(self)
    }
}
