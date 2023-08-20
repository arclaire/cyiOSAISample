//
//  SDCameraBottomView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/10/29.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit
import Photos

@objc enum CameraPositionType: Int {
    case front
    case back
}

@objc enum ScreenSizeType: Int {
    case full
    case size11
    case size169
}

@objc enum ShowFilterType: Int {
    case hide
    case show
}

@objc enum ShowEffectsType: Int {
    case hide
    case show
}

@objc protocol SDCameraBottomViewDelegate: NSObjectProtocol {
    func clickAlbumFundation()
    func clickSwitchCameraFundation(position type: CameraPositionType)
    func clickTakePhotoFundation()
    //func clickScreenSizeFundation(screenSize type: ScreenSizeType)
    func clickShowFilterFundation(showType type: ShowFilterType)
    func clickShowFilterEffectsFundation(showType type: ShowEffectsType)
    
}

class ALCameraBottomView: UIView {
    
    weak var bottomViewDelegate: SDCameraBottomViewDelegate?
    
    var positionType: CameraPositionType = .front
    var sizeType: ScreenSizeType = .full
    var filterType: ShowFilterType = .hide {
        didSet {
            if filterType == .hide {
                filterBtn.setImage(UIImage(named: "camera_filter"), for: .normal)
            }
            
        }
    }
    
    var effectsType: ShowEffectsType = .hide {
        didSet {
            if effectsType == .hide {
                screenSizeBtn.setImage(UIImage(named: "editor_effects"), for: .normal)
            }
            
        }
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializerData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    @objc func clickAlbunButton() {
        if let delegate = bottomViewDelegate {
            delegate.clickAlbumFundation()
        }
    }
    
    @objc func clickSwitchCameraButton() {
        if positionType == .front {
            positionType = .back
        }else {
            positionType = .front
        }
        
        if let delegate = bottomViewDelegate {
            delegate.clickSwitchCameraFundation(position: positionType)
        }
    }
    
    @objc func clickTakePhotoButton() {
        if let delegate = bottomViewDelegate {
            delegate.clickTakePhotoFundation()
        }
    }
    
    @objc func clickFilterEffectButton() {
        if self.filterType == .show {
           self.filterType = .hide
            filterBtn.setImage(UIImage.init(named: "camera_filter"), for: .normal)
        }
        
        if effectsType == .hide {
            effectsType = .show
            screenSizeBtn.setImage(UIImage.init(named: "editor_effects_pink"), for: .normal)
        }else {
            effectsType = .hide
            screenSizeBtn.setImage(UIImage.init(named: "editor_effects"), for: .normal)
        }
        
        if let delegate = bottomViewDelegate {
            delegate.clickShowFilterEffectsFundation(showType: effectsType)
            delegate.clickShowFilterFundation(showType: self.filterType)
        }
    }
    
    @objc func clickShowFilterButton() {
        if self.effectsType == .show {
            self.effectsType = .hide
            screenSizeBtn.setImage(UIImage.init(named: "editor_effects"), for: .normal)
        }
        if filterType == .hide {
            filterType = .show
            filterBtn.setImage(UIImage.init(named: "camera_filter_pink"), for: .normal)
        }else {
            filterType = .hide
            filterBtn.setImage(UIImage.init(named: "camera_filter"), for: .normal)
        }
        
        if let delegate = bottomViewDelegate {
            delegate.clickShowFilterFundation(showType: self.filterType)
            delegate.clickShowFilterEffectsFundation(showType: self.effectsType)
        }
    }
    
    
    // MARK: - Lazying View

    lazy var albumBtn: UIButton = {
        let albumBtn = UIButton()
        albumBtn.alpha = 0.5
        albumBtn.frame = CGRect(x: 0, y: 0, width: 30.adaptScreenWidth(), height: 30.adaptScreenWidth())
        albumBtn.setImage(UIImage(named: "camera_gallery"), for: .normal)
        
        return albumBtn
    }()
    
    lazy var switchCameraBtn: UIButton = {
        let switchCameraBtn = UIButton()
        switchCameraBtn.alpha = 0.5
        switchCameraBtn.frame = CGRect(x: 0, y: 0, width: 30.adaptScreenWidth(), height: 30.adaptScreenWidth())
        switchCameraBtn.setImage(UIImage(named: "camera_switch"), for: .normal)
        
        return switchCameraBtn
    }()
    
    lazy var takePhotoBtn: UIButton = {
        let takePhotoBtn = UIButton()
        takePhotoBtn.alpha = 0.5
        takePhotoBtn.frame = CGRect(x: 0, y: 0, width: 70.adaptScreenWidth(), height: 70.adaptScreenWidth())
        takePhotoBtn.setImage(UIImage(named: "camera_take_photo"), for: .normal)
        
        return takePhotoBtn
    }()
    
    lazy var screenSizeBtn: UIButton = {
        let screenSizeBtn = UIButton()
        screenSizeBtn.alpha = 0.5
        screenSizeBtn.frame = CGRect(x: 0, y: 0, width: 30.adaptScreenWidth(), height: 30.adaptScreenWidth())
        screenSizeBtn.setImage(UIImage(named: "editor_effects"), for: .normal)
        
        return screenSizeBtn
    }()
    
    lazy var filterBtn: UIButton = {
        let filterBtn = UIButton()
        filterBtn.alpha = 0.5
        filterBtn.frame = CGRect(x: 0, y: 0, width: 30.adaptScreenWidth(), height: 30.adaptScreenWidth())
        filterBtn.setImage(UIImage(named: "camera_filter"), for: .normal)
        
        return filterBtn
    }()
    
}


// MARK: - SDNormalCameraBottomView

class SDNormalCameraBottomView: ALCameraBottomView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHeriarchy()
        
        observeGenerationDeviceOrientationNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserveGenerationDeviceOrientationNotifications()
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    @objc override func clickShowFilterButton() {
        super.clickShowFilterButton()
        
    }
    
    @objc override func clickFilterEffectButton() {
        super.clickFilterEffectButton()
       
    }
    
}

extension SDNormalCameraBottomView {
    
    private func configureHeriarchy() {
        addSubview(albumBtn)
        addSubview(switchCameraBtn)
        addSubview(takePhotoBtn)
        addSubview(screenSizeBtn)
        addSubview(filterBtn)
        
        albumBtn.addTarget(self, action: #selector(clickAlbunButton), for: .touchUpInside)
        switchCameraBtn.addTarget(self, action: #selector(clickSwitchCameraButton), for: .touchUpInside)
        takePhotoBtn.addTarget(self, action: #selector(clickTakePhotoButton), for: .touchUpInside)
        screenSizeBtn.addTarget(self, action: #selector(clickFilterEffectButton), for: .touchUpInside)
        filterBtn.addTarget(self, action: #selector(clickShowFilterButton), for: .touchUpInside)
        
        let postion = CGPoint(x: SDConstants.UI.Screen_Width/2, y: 35)
        albumBtn.center = postion
        switchCameraBtn.center = postion
        takePhotoBtn.center = postion
        screenSizeBtn.center = postion
        filterBtn.center = postion
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            
            let y = 35.cgFloat
            self.albumBtn.alpha = 1.0
            self.albumBtn.center = CGPoint(x: (40.adaptScreenWidth() + 30.adaptScreenWidth()/2), y: y)
            self.switchCameraBtn.alpha = 1.0
            self.switchCameraBtn.center = CGPoint(x: (113.adaptScreenWidth() + 30.adaptScreenWidth()/2), y: y)

            self.screenSizeBtn.alpha = 1.0
            self.screenSizeBtn.center = CGPoint(x: (SDConstants.UI.Screen_Width - 113.adaptScreenWidth() - 30.adaptScreenWidth()/2), y: y)
            self.filterBtn.alpha = 1.0
            self.filterBtn.center = CGPoint(x: (SDConstants.UI.Screen_Width - 40.adaptScreenWidth() - 30.adaptScreenWidth()/2), y: y)
            
        }) { (bool) in
            
        }
    }
    
}

extension ALCameraBottomView {
    private func initializerData() {
        SDPhotoManager.sharedInstance.authoring { (success) in
            if success {
                SDPhotoManager.sharedInstance.latestPhotoAsset { (asset) in
                    guard let `asset` = asset else { return }
                    
                    SDPhotoManager.sharedInstance.thumbForPhotoAsset(asset: asset, desireSize: CGSize(width: 30, height: 30)) { (image) in
                        
                        DispatchQueue.main.async {
                            self.albumBtn.setImage(image, for: .normal)
                        }
                        
                    }
                    // register to know if Photos changed
                    PHPhotoLibrary.shared().register(self)
                }
            }
        }
        
    }
}

extension ALCameraBottomView: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.initializerData()
    }
}


// MARK: -

extension SDNormalCameraBottomView: SDGeneratingDeviceOrientationDelegate {
    func handleDeviceOrientationChange(orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeLeft:
            UIView.animate(withDuration: 0.5) {
                self.albumBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.switchCameraBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.screenSizeBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.filterBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
            }
            
            break
        case .landscapeRight:
            UIView.animate(withDuration: 0.5) {
                self.albumBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.switchCameraBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.screenSizeBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.filterBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
            }
            
            break

        case .portrait:
            UIView.animate(withDuration: 0.5) {
                self.albumBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.switchCameraBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.screenSizeBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.filterBtn.transform = CGAffineTransform.init(rotationAngle: 0)
            }
            
            break
        case .portraitUpsideDown:
            UIView.animate(withDuration: 0.5) {
                self.albumBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.switchCameraBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.screenSizeBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.filterBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
            }
            
            break
        
        default:
            break
        }
    }
    
}


// MARK: - SDAgingCameraBottomView

class SDFewerCameraBottomView: ALCameraBottomView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializerData()
        configureHeriarchy()
        
        observeGenerationDeviceOrientationNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserveGenerationDeviceOrientationNotifications()
    }
    
}

extension SDFewerCameraBottomView {
    private func initializerData() {
        SDPhotoManager.sharedInstance.authoring { (success) in
            if success {
                SDPhotoManager.sharedInstance.latestPhotoAsset { (asset) in
                    guard let `asset` = asset else { return }
                    
                    SDPhotoManager.sharedInstance.thumbForPhotoAsset(asset: asset, desireSize: CGSize(width: 30, height: 30)) { (image) in
                        
                        DispatchQueue.main.async {
                            self.albumBtn.setImage(image, for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    private func configureHeriarchy() {
        addSubview(albumBtn)
        addSubview(takePhotoBtn)
        addSubview(switchCameraBtn)
        
        albumBtn.addTarget(self, action: #selector(clickAlbunButton), for: .touchUpInside)
        takePhotoBtn.addTarget(self, action: #selector(clickTakePhotoButton), for: .touchUpInside)
        switchCameraBtn.addTarget(self, action: #selector(clickSwitchCameraButton), for: .touchUpInside)
        
        let postion = CGPoint(x: SDConstants.UI.Screen_Width/2, y: 35)
        albumBtn.center = postion
        takePhotoBtn.center = postion
        switchCameraBtn.center = postion
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            
            let y = 35.cgFloat
            self.albumBtn.alpha = 1.0
            self.albumBtn.center = CGPoint(x: (75.adaptScreenWidth() + 30.adaptScreenWidth()/2), y: y)
            self.switchCameraBtn.alpha = 1.0
            self.switchCameraBtn.center = CGPoint(x: (SDConstants.UI.Screen_Width - 75.adaptScreenWidth() - 30.adaptScreenWidth()/2), y: y)
            
        }) { (bool) in
            
        }
    }
    
}


// MARK: -

extension SDFewerCameraBottomView: SDGeneratingDeviceOrientationDelegate {
    func handleDeviceOrientationChange(orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeLeft:
            UIView.animate(withDuration: 0.5) {
                self.albumBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.switchCameraBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                
            }
            
            break
        case .landscapeRight:
            UIView.animate(withDuration: 0.5) {
                self.albumBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.switchCameraBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
            }
            
            break

        case .portrait:
            UIView.animate(withDuration: 0.5) {
                self.albumBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.switchCameraBtn.transform = CGAffineTransform.init(rotationAngle: 0)
            }
            
            break
        
        default:
            break
        }
    }
}
