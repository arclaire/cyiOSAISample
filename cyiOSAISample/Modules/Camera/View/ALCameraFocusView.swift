//
//  SDCameraFocusView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/21.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class ALCameraFocusView: UIView, CAAnimationDelegate {

    private var borderLayer: CALayer!
    private var innerCircleLayer: CALayer!
    private static let ANIMATION_KEY = "Inner_Animation"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawButton()
    }
    
    private func drawButton() {
        self.backgroundColor = UIColor.clear
        borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.borderWidth = 6.0
        borderLayer.borderColor = UIColor.white.cgColor
        borderLayer.bounds = self.bounds
        borderLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        borderLayer.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(borderLayer, at: 0)
        
        innerCircleLayer = CALayer()
        innerCircleLayer.backgroundColor = UIColor.clear.cgColor
        innerCircleLayer.borderWidth = 3.0
        innerCircleLayer.borderColor = UIColor.white.cgColor
        innerCircleLayer.bounds = CGRect(x: 0.0, y: 0.0, width: bounds.width * 2.0 / 3.0, height: bounds.height * 2.0 / 3.0)
        innerCircleLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        innerCircleLayer.cornerRadius = self.bounds.width / 3.0
        layer.insertSublayer(innerCircleLayer, at: 1)
    }
    
    func showAt(_ point: CGPoint) {
        self.isHidden = false
        self.center = point
        
        innerCircleLayer.removeAnimation(forKey: ALCameraFocusView.ANIMATION_KEY)
        innerCircleLayer.transform = CATransform3DMakeScale(0.50, 0.50, 0.50)
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.66, -0.65, 0.33, 0.99)
        animation.fromValue = CATransform3DIdentity
        animation.toValue = CATransform3DMakeScale(0.50, 0.50, 0.50)
        animation.fillMode = .backwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        innerCircleLayer.add(animation, forKey: ALCameraFocusView.ANIMATION_KEY)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenAction), object: nil)
            self.perform(#selector(hiddenAction), with: nil, afterDelay: 0.2)
        }
    }
    
    @objc func hiddenAction() {
        self.isHidden = true
    }

}
