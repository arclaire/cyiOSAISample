//
//  AppDelegate.swift
//  cyiOSAISample
//
//  Created by Lucy on 18/08/23.
//

import UIKit

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.portrait

    var router: ALRouter?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
      
        
        if let window = self.window {
            self.router = ALRouter(window: window)
            self.router?.create()
        }
        
        
        // The start method will actually fisrtCoordinator?.start()
        
        window?.makeKeyAndVisible()
      
        // Override point for customization after application launch.
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    
    class func sharedInstance() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }

}

