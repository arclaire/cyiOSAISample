//
//  ButtonController.swift
//  cyiOSAISample
//
//  Created by Michael on 27/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

protocol GeneralButtonDelegate: NSObjectProtocol {
    func didButtonClick(_ button: GeneralButton)
}

class GeneralButton: UIView {
    weak var delegate: GeneralButtonDelegate?
    
    var onClick: (()->Void)?
    
    var imgView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.isUserInteractionEnabled = true
        
        setInitial()
    }
    
    var image: UIImage? {
        get {
            return imgView.image
        }
        set {
            imgView.image = newValue
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let point = touch.location(in: self)
        if self.bounds.contains(point) {
            if self.delegate != nil {
                self.delegate?.didButtonClick(self)
            }
            
            if self.onClick != nil {
                self.onClick?()
            }
        }
    }
    
    private func setInitial() {
        self.addSubview(imgView)
        
        imgView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
}

class ScaleButton: GeneralButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.20, animations: {
            self.transform = .identity
        }) { _ in
            guard let touch = touches.first else {
                return
            }
            
            let point = touch.location(in: self)
            if self.bounds.contains(point) {
                if self.delegate != nil {
                    self.delegate?.didButtonClick(self)
                }
                
                if self.onClick != nil {
                    self.onClick?()
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.20) {
            self.transform = .identity
        }
    }
}

protocol HoldButtonDelegate: NSObjectProtocol {
    func didButtonHold(_ button: HoldButton)
    func didButtonUnhold(_ button: HoldButton)
}

class HoldButton: UIView {
    weak var delegate: HoldButtonDelegate?
    var onClick: (()->Void)?
    
    private var imgView: UIImageView!
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.isUserInteractionEnabled = true
        
        setInitial()
    }
    
    var image: UIImage? {
        get {
            return imgView.image
        }
        set {
            imgView.image = newValue
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.delegate != nil {
            self.delegate?.didButtonHold(self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.delegate != nil {
            self.delegate?.didButtonUnhold(self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.delegate != nil {
            self.delegate?.didButtonUnhold(self)
        }
    }
    
    private func setInitial() {
        imgView = UIImageView()
        self.addSubview(imgView)
        
        imgView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
}

protocol CircularProgressViewDelegate: NSObjectProtocol {
    func didCircularStarted()
    func didCircularFinished()
}

class CirculateButton: GeneralButton {
    weak var circulateDelegate: CircularProgressViewDelegate?
    
    lazy var vwCircular: CircularProgressView = {
        let vwCircular = CircularProgressView()
        vwCircular.delegate = circulateDelegate
        return vwCircular
    }()
    
    init(circulateDelegate: CircularProgressViewDelegate) {
        super.init()
        
        self.circulateDelegate = circulateDelegate
        
        setInitial()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.20, animations: {
            self.transform = .identity
        }) { _ in
            guard let touch = touches.first else {
                return
            }
            
            let point = touch.location(in: self)
            if self.bounds.contains(point) {
                if self.delegate != nil {
                    self.delegate?.didButtonClick(self)
                }
                
                if self.onClick != nil {
                    self.onClick?()
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.20) {
            self.transform = .identity
        }
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        self.vwCircular.setProgressWithAnimation(duration: duration, value: value)
    }
    
    func clear() {
        self.vwCircular.clear()
    }
    
    private func setInitial() {
        self.addSubview(vwCircular)
        
        self.imgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().offset(20)
        }
        
        vwCircular.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

class CircularProgressView: UIView, CAAnimationDelegate {
    weak var delegate: CircularProgressViewDelegate?
    
    var progressLyr = CAShapeLayer()
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        makeCircularPath()
    }
    
    var progressClr = UIColor.gray {
        didSet {
            progressLyr.strokeColor = progressClr.cgColor
        }
    }
    
    func makeCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        progressLyr.path = circlePath.cgPath
        progressLyr.fillColor = UIColor.clear.cgColor
        progressLyr.strokeColor = progressClr.cgColor
        progressLyr.lineWidth = 5.0
        progressLyr.strokeEnd = 0.0
        layer.addSublayer(progressLyr)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLyr.strokeEnd = CGFloat(value)
        progressLyr.add(animation, forKey: "animateprogress")
    }
    
    func clear() {
        progressLyr.removeAllAnimations()
        progressLyr.strokeEnd = 0.0
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        if self.delegate != nil {
            self.delegate?.didCircularStarted()
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.clear()
        
        if self.delegate != nil {
            self.delegate?.didCircularFinished()
        }
    }
}
