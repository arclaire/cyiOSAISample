//
//  SDCameraTopView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/10/29.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit
import SnapKit


@objc enum ReticleType: Int {
    case hide
    case show
}

@objc enum FlashType: Int {
    case off
    case on
    case auto
}

@objc enum TimerType: Int {
    case s0
    case s3
    case s5
    case s10
}

@objc protocol SDCameraViewDelegate: NSObjectProtocol {
    func clickReturnFundation()
    func clickReticleFundationWithType(reticle type: ReticleType)
    func clickFalshFundationWithType(falsh type: FlashType)
    func clickTimerFundationWithType(timer type: TimerType)
    func clickScreenSizeFundation(screenSize type: ScreenSizeType)
}


class ALCameraTopView: UIView {
    
    weak var topviewDelegate: SDCameraViewDelegate?
    
    var reticleType: ReticleType = .hide
    var flashType: FlashType = .off
    var timerType: TimerType = .s0
    var sizeType: ScreenSizeType = .full
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    @objc func clickReturnButton() {
        if let delegate = topviewDelegate {
            delegate.clickReturnFundation()
        }
    }
    
    @objc func clickReticleButton() {
        if reticleType == .show {
            reticleType = .hide
        }else if reticleType == .hide{
            reticleType = .show
        }
        
        if let delegate = topviewDelegate {
            delegate.clickReticleFundationWithType(reticle: reticleType)
        }
    }
    
    @objc func clickFalshButton() {
        if flashType == .off {
            flashType = .on
            falshBtn.setImage(UIImage(named: "camera_falsh_on"), for: .normal)
        }else if flashType == .on {
            flashType = .auto
            falshBtn.setImage(UIImage(named: "camera_falsh_auto"), for: .normal)
        }else if flashType == .auto {
            flashType = .off
            falshBtn.setImage(UIImage(named: "camera_falsh_off"), for: .normal)
        }
        
        if let deleagte = topviewDelegate {
            deleagte.clickFalshFundationWithType(falsh: flashType)
        }
    }
    
    @objc func clickTimerButton() {
        if timerType == .s3 {
            timerType = .s5
            timerBtn.setImage(UIImage(named: "camera_timer_5"), for: .normal)
        }else if timerType == .s5 {
            timerType = .s10
            timerBtn.setImage(UIImage(named: "camera_timer_10"), for: .normal)
        }else if timerType == .s10 {
            timerType = .s0
            timerBtn.setImage(UIImage(named: "camera_timer_off"), for: .normal)
        }else if timerType == .s0 {
            timerType = .s3
            timerBtn.setImage(UIImage(named: "camera_timer_3"), for: .normal)
        }
        
        let transition = CATransition()
        transition.type = CATransitionType(rawValue: "cube")
        transition.subtype = CATransitionSubtype.fromTop
        transition.duration = 0.5
        
        timerBtn.layer.add(transition, forKey: "cubeAnimation")
        
        if let deleagte = topviewDelegate {
            deleagte.clickTimerFundationWithType(timer: timerType)
        }
    }
    
    
    @objc func clickScreenSizeButton() {
        if  sizeType == .full {
            sizeType = .size11
            screenSizeBtn.setImage(UIImage(named: "camera_ratio_1:1"), for: .normal)
        }else if sizeType == .size11 {
            sizeType = .size169
            screenSizeBtn.setImage(UIImage(named: "camera_ratio_16:9"), for: .normal)
        }else if sizeType == .size169{
            sizeType = .full
            screenSizeBtn.setImage(UIImage(named: "camera_ratio_full"), for: .normal)
        }
        
        if let delegate = topviewDelegate {
            delegate.clickScreenSizeFundation(screenSize: sizeType)
        }
    }
    
    // MARK: - Lazying View
    
    lazy var returnBtn: UIButton = {
        let returnBtn = UIButton()
        returnBtn.setImage(UIImage(named: "common_back"), for: .normal)
        
        return returnBtn
    }()
    
    lazy var reticleBtn: UIButton = {
        let reticleBtn = UIButton()
        reticleBtn.setImage(UIImage(named: "camera_reticle"), for: .normal)
        
        return reticleBtn
    }()
    
    lazy var falshBtn: UIButton = {
        let falshBtn = UIButton()
        falshBtn.setImage(UIImage(named: "camera_falsh_off"), for: .normal)
        
        return falshBtn
    }()
    
    lazy var timerBtn: UIButton = {
        let timerBtn = UIButton()
        timerBtn.setImage(UIImage(named: "camera_timer_off"), for: .normal)
        
        return timerBtn
    }()
    
    lazy var screenSizeBtn: UIButton = {
        let screenSizeBtn = UIButton()
        screenSizeBtn.frame = CGRect(x: 0, y: 0, width: 30.adaptScreenWidth(), height: 30.adaptScreenWidth())
        screenSizeBtn.setImage(UIImage(named: "camera_ratio_full"), for: .normal)
        
        return screenSizeBtn
    }()
}


// MARK: - SDNormalCameraTopView

class SDNormalCameraTopView: ALCameraTopView {
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

extension SDNormalCameraTopView {
    private func initializerData() {
        
    }
    
    private func configureHeriarchy() {
        addSubview(returnBtn)
        addSubview(reticleBtn)
        addSubview(falshBtn)
        addSubview(screenSizeBtn)
        addSubview(timerBtn)
        
        returnBtn.addTarget(self, action: #selector(clickReturnButton), for: .touchUpInside)
        reticleBtn.addTarget(self, action: #selector(clickReticleButton), for: .touchUpInside)
        falshBtn.addTarget(self, action: #selector(clickFalshButton), for: .touchUpInside)
        timerBtn.addTarget(self, action: #selector(clickTimerButton), for: .touchUpInside)
        self.screenSizeBtn.addTarget(self, action: #selector(clickScreenSizeButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        returnBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16.adaptBangS())
            make.left.equalToSuperview().offset(40.adaptScreenWidth())
            make.width.height.equalTo(30.adaptScreenWidth())
        }
        
        reticleBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16.adaptBangS())
            make.left.equalTo(returnBtn.snp.right).offset(50.adaptScreenWidth())
            make.width.height.equalTo(30.adaptScreenWidth())
        }
        
        falshBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16.adaptBangS())
            make.right.equalTo(screenSizeBtn.snp.left).offset(-50.adaptScreenWidth())
            make.width.height.equalTo(30.adaptScreenWidth())
        }
        screenSizeBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16.adaptBangS())
            make.right.equalTo(timerBtn.snp.left).offset(-50.adaptScreenWidth())
            make.width.height.equalTo(30.adaptScreenWidth())
        }
        timerBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16.adaptBangS())
            make.right.equalToSuperview().offset(-40.adaptScreenWidth())
            make.width.height.equalTo(30.adaptScreenWidth())
        }
    }
}

extension SDNormalCameraTopView: SDGeneratingDeviceOrientationDelegate {
    func handleDeviceOrientationChange(orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeLeft:
            UIView.animate(withDuration: 0.5) {
                self.returnBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.reticleBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.falshBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.timerBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.screenSizeBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
            }
            
            break
        case .landscapeRight:
            UIView.animate(withDuration: 0.5) {
                self.returnBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.reticleBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.falshBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.timerBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.screenSizeBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
            }
            
            break

        case .portrait:
            UIView.animate(withDuration: 0.5) {
                self.returnBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.reticleBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.falshBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.timerBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.screenSizeBtn.transform = CGAffineTransform.init(rotationAngle: 0)
            }
            
            break
            
        case .portraitUpsideDown:
            UIView.animate(withDuration: 0.5) {
                self.returnBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.reticleBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.falshBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.timerBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.screenSizeBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
            }
            
            break
        
        default:
            break
        }
    }
    
}


// MARK: - SDAgingCameraTopView

class SDAgingCameraTopView: ALCameraTopView {
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

extension SDAgingCameraTopView {
    private func initializerData() {
        
    }
    
    private func configureHeriarchy() {
        addSubview(returnBtn)
        addSubview(reticleBtn)
        addSubview(falshBtn)
        
        returnBtn.addTarget(self, action: #selector(clickReturnButton), for: .touchUpInside)
        reticleBtn.addTarget(self, action: #selector(clickReticleButton), for: .touchUpInside)
        falshBtn.addTarget(self, action: #selector(clickFalshButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           
           returnBtn.snp.makeConstraints { (make) in
               make.top.equalToSuperview().offset(20.adaptBangS())
               make.left.equalToSuperview().offset(40.adaptScreenWidth())
               make.width.height.equalTo(30.adaptScreenWidth())
           }
           
           reticleBtn.snp.makeConstraints { (make) in
               make.top.equalToSuperview().offset(20.adaptBangS())
               make.centerX.equalTo(self.snp.centerX)
               make.width.height.equalTo(30.adaptScreenWidth())
           }
           
           falshBtn.snp.makeConstraints { (make) in
               make.top.equalToSuperview().offset(20.adaptBangS())
               make.right.equalToSuperview().offset(-40.adaptScreenWidth())
               make.width.height.equalTo(30.adaptScreenWidth())
           }
           
       }
}

extension SDAgingCameraTopView: SDGeneratingDeviceOrientationDelegate {
    func handleDeviceOrientationChange(orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeLeft:
            UIView.animate(withDuration: 0.5) {
                self.returnBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.reticleBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                self.falshBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
                
            }
            
            break
        case .landscapeRight:
            UIView.animate(withDuration: 0.5) {
                self.returnBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.reticleBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                self.falshBtn.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
                
            }
            
            break

        case .portrait:
            UIView.animate(withDuration: 0.5) {
                self.returnBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.reticleBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                self.falshBtn.transform = CGAffineTransform.init(rotationAngle: 0)
                
            }
            
            break
            
        case .portraitUpsideDown:
            UIView.animate(withDuration: 0.5) {
                self.returnBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.reticleBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                self.falshBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
            }
            
            break
        
        default:
            break
        }
    }
    
}


