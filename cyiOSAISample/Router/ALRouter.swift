//
//  ALRouter.swift
//  cyiOSAISample
//
//  Created by Lucy on 13/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation
class ALRouter: Router {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func create() {
        //let navigationController = UINavigationController()
        //window.rootViewController = navigationController
        //window.makeKeyAndVisible()
        
        let route = ALRouterSplash()
        self.routeTo(route: route)
    }
    
   
    
   
}
