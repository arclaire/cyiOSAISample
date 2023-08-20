//
//  SplashViewController.swift
//  cyiOSAISample
//
//  Created by Lucy on 13/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.splashTimeOut(sender:)), userInfo: nil, repeats: false)
       
    }


    @objc func splashTimeOut(sender : Timer){
        let routeToHome = ALRouterHome()
        routeToHome.create()
        
    }
}
