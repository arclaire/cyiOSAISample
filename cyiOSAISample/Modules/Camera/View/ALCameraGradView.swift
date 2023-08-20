//
//  SDCameraGradView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/10/31.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class ALCameraGradView: UIView {
    
    init(inView: UIView) {
        super.init(frame: inView.bounds)
        inView.addSubview(self)
        configureHeriachyView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawGrid()
    }
}


// MARK: - Public Method

extension ALCameraGradView {
    public func show() {
        self.isHidden = false
    }
    
    public func hide() {
        self.isHidden = true
    }
}


// MARK: - Private Method

extension ALCameraGradView {
    
    private func drawWithRect(rect: CGRect) {
        let lineLayer = CALayer()
        lineLayer.frame = rect
        layer.addSublayer(lineLayer)
        lineLayer.backgroundColor = UIColor.RGBA(r: 255, g: 255, b: 255, a: 0.3).cgColor
        
    }
    
    private func configureHeriachyView() {
        self.isUserInteractionEnabled = false
        backgroundColor = .clear
        isHidden = true
        drawGrid()
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func drawGrid() {
        if let items = self.layer.sublayers {
            for layer in items {
                layer.removeFromSuperlayer()
            }
        }
        
        let lineWidth: CGFloat = 1
        let lineCount = 2
        let lineHorSpace = self.frame.size.width / (lineCount+1).cgFloat
        let lineVerSpace = self.frame.size.height / (lineCount+1).cgFloat
        let width = self.frame.size.width
        let height = self.frame.size.height
        let originX = self.frame.origin.x
        let originY = self.frame.origin.y
        //draw horizontal line
        for i in 0..<lineCount {
            autoreleasepool {
                drawWithRect(rect: CGRect(x: 0, y: originY + lineVerSpace*CGFloat(i+1), width: width, height: lineWidth))
            }
        }
        //draw vertical line
        for i in 0..<lineCount {
            autoreleasepool {
                drawWithRect(rect: CGRect(x: originX + lineHorSpace*CGFloat(i+1), y: 0, width: lineWidth, height: height))
            }
        }
    }
}

