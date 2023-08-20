//
//  ALRouterHome.swift
//  cyiOSAISample
//
//  Created by Lucy on 14/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation


class ALRouterHome: Router {
    
    var navigationController: UINavigationController?

    func create() {
        let vc = HomeViewController()
        self.navigationController = UINavigationController(rootViewController: vc)
        self.navigationController?.isNavigationBarHidden = true
        AppDelegate.sharedInstance().window?.rootViewController = self.navigationController
        
    }
   
}
