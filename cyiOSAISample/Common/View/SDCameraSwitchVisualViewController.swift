//
//  SDCameraSwitchVisualViewController.swift
//  cyiOSAISample
//
//  Created by Lucy on 12/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation


class SDCameraSwitchVisualViewController {
    
    class func show(parent viewController: UIViewController) {
        let visualView: SDVisualEffectView = {
            let visualView = SDVisualEffectView(blurRadius: 10, scale: SDConstants.UI.Screen_Scale, colorTintAlpha: 0.6)
            visualView.backgroundColor = UIColor.RGBA(r: 175, g: 228, b: 255, a: 0.6)
            visualView.frame = viewController.view.bounds
            
            return visualView
        }()
        
        viewController.view.addSubview(visualView)
        
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseOut, animations: {
            visualView.alpha = 0
        }) { (finish) in
            if(visualView.superview != nil){
                visualView.removeFromSuperview()
            }
        }
    }
}
