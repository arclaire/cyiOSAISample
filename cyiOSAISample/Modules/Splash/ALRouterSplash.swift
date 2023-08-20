//
//  ALRouterSplash.swift
//  cyiOSAISample
//
//  Created by Lucy on 13/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation
import UIKit

class ALRouterSplash: Router {
    
    func create() {
        let vc = SplashViewController()
        AppDelegate.sharedInstance().window?.rootViewController = vc
        
    }
    
    init() {
       
    }
        
  
}


