//
//  PCAppController.swift
//  cyiOSAISample
//
//  Created by Lucy on 12/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation
import Lottie
class PCAppController: NSObject {
    
    static let sharedInstance = PCAppController()
    
    private var vwLoading: UIView?
    //private var splashLoading : AnimationView?
    private var vwSaveConfirmed: UIView?
    //private var vwToast: SDToastView?
    
    func showToast(message : String) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = message.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 15) ?? nil], context: nil)
        let width = labelSize.width + 50
        let originX = (UIScreen.main.bounds.width - width) / 2
       
        let toastLabel = UILabel(frame: CGRect(x: originX, y: (appDelegate.window?.frame.size.height ?? 0)/2 + 100, width: width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.font = UIFont(name: "RobotoCondensed-Regular", size: 15)
        appDelegate.window?.addSubview(toastLabel)
        UIView.animate(withDuration: 2.5, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    public func askPermission(_ onView: UIView, forPermission:String) -> Void{
//        self.vwLoading = UIView.init(frame: onView.bounds)
//        vwLoading!.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//
//        onView.addSubview(self.vwLoading!)
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        blurView.frame = onView.bounds
//        vwLoading?.addSubview(blurView)
//        
//        let permissionView = self.permissionView(permission: forPermission)
//        vwLoading?.addSubview(permissionView)
//        permissionView.snp.makeConstraints({ (make) in
//            make.centerX.centerY.equalToSuperview()
//            make.height.equalTo(356)
//            make.width.equalTo(320)
//        })
    }
    
    public func closePermissionView() -> Void {
        self.vwLoading?.removeFromSuperview()
    }
}

extension PCAppController {
    public func openLoadingViewSplash(_ viewController: UIViewController) -> Void {
        if self.vwLoading == nil {
            let path = SDFileController.getMainBundle("Logo", resourceName: "data", type: "json")
            //self.splashLoading = AnimationView.init(filePath: path)
            //self.splashLoading?.loopMode = .loop
        }
        //viewController.view.addSubview(self.splashLoading!)
//        self.splashLoading?.snp.makeConstraints {
//            $0.center.equalTo(viewController.view)
//            $0.width.equalToSuperview().multipliedBy(0.3)
//            $0.height.equalTo(self.splashLoading!.snp_width)
//        }
        //self.splashLoading?.play()
    }

    
    public func openLoadingView(viewController: UIViewController, isDarkMode : Bool = false) -> Void {
        self.openLoadingView(view: viewController.view, isDarkMode: isDarkMode)
    }
    
    public func openLoadingView(view: UIView, isDarkMode: Bool = false) -> Void {
        self.vwLoading = UIView.init()
        view.addSubview(self.vwLoading!)
        vwLoading!.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        let blurEffect = UIBlurEffect(style: isDarkMode ? .dark : .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.99
        blurView.frame = view.bounds
        vwLoading?.addSubview(blurView)
        
        let path = SDFileController.getMainBundle("Loading", resourceName: "data", type: "json")
        let loadingView = LottieAnimationView(filePath: path)
        loadingView.loopMode = .loop
        self.vwLoading?.addSubview(loadingView)
        loadingView.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.height.equalTo(100)
            make.width.equalTo(100)
        })
        let lblInfo: UILabel = {
            let label = UILabel()
            label.text = "Processing"
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont(name: "SFProText-Light", size: 12)
            
            return label
        }()
        self.vwLoading?.addSubview(lblInfo)
        lblInfo.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(100)
            make.top.equalTo(loadingView.snp_bottom).offset(20)
        }
        
        loadingView.play()
    }
    
    public func openLoadingBoxView(viewController: UIViewController) -> Void {
        self.openLoadingBoxView(view: viewController.view)
    }
    
    public func openLoadingBoxView(view: UIView) -> Void {
        self.vwLoading = UIView.init()
        view.addSubview(self.vwLoading!)
        vwLoading!.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        vwLoading?.addSubview(blurView)
        
        let path = SDFileController.getMainBundle("LoadingBox", resourceName: "data", type: "json")
        let loadingView = LottieAnimationView(filePath: path)
        loadingView.loopMode = .loop
        self.vwLoading?.addSubview(loadingView)
        loadingView.snp.makeConstraints({ (make) in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(100)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        })
        loadingView.play()
    }
    
    public func makeTransparentOverlayView(viewController: UIViewController) -> Void{
        self.makeTransparentOverlayView(view: viewController.view)
    }
    
    public func makeTransparentOverlayView(view: UIView) -> Void{
        self.vwLoading = UIView.init()
        view.addSubview(self.vwLoading!)
        vwLoading!.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.4
        blurView.frame = view.bounds
        vwLoading?.addSubview(blurView)
    }
    
    public func closeLoadingView() -> Void {
        if let notnil = self.vwLoading?.superview {
            self.vwLoading?.removeFromSuperview()
        }
    }
    
}
