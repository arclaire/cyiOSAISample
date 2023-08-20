//
//  SDCustomSlider.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/12.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class SDCustomSlider: UISlider {

    var labelSize: CGSize = CGSize(width: 60, height: 60)
    var rowSpacing: CGFloat = 25
    
    var lastRect: CGRect = .zero
    
    var isValueDirectEnable: Bool = false
    var valueDirect: String? {
        didSet {
            isValueDirectEnable = true
            valueLabel.text = valueDirect!
        }
    }
    
    private var valueLabel: UILabel = UILabel()
    
    var showPresenter: Bool = false {
        didSet {
            if showPresenter {
                self.valueLabel.isHidden = false
            } else {
                self.valueLabel.isHidden = true
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(valueLabel)
    }
    
    private func initView() {
        let circleImage = makeCircleWith(size: CGSize(width: 20, height: 20), backgroundColor: UIColor.blue)
        setThumbImage(circleImage, for: .normal)
        setThumbImage(circleImage, for: .highlighted)
        minimumTrackTintColor = UIColor.yellow
        maximumTrackTintColor = .white
        minimumValue = 0
        maximumValue = 100
//        valueLabel = UILabel()
//        valueLabel.isHidden = true
//        valueLabel.textColor = UIColor(named: "333333")
//        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
//        valueLabel.textAlignment = .center
//        valueLabel.layer.masksToBounds = true
//        valueLabel.layer.cornerRadius = labelSize.width / 2
//        addSubview(valueLabel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //setThumbImage(UIImage.createImageWithColor(color: UIColor(named: "editor_thumb")!), for: .normal)
        let circleImage = makeCircleWith(size: CGSize(width: 20, height: 20), backgroundColor: UIColor.blue)
        setThumbImage(circleImage, for: .normal)
        setThumbImage(circleImage, for: .highlighted)
        minimumTrackTintColor = UIColor.yellow
        
        maximumTrackTintColor = .white
        minimumValue = 0
        maximumValue = 100
    }
    
//    public override func trackRect(forBounds bounds: CGRect) -> CGRect {
//        let trackHeight: CGFloat = 6.0
//        
//        print("bounds : \(bounds)")
//        
//        return CGRect(x: 0.0, y: (bounds.height - trackHeight) / 2, width: bounds.width, height: trackHeight)
//    }
    
//    public override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
//        var zeroRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: 0.0)
//        var oneRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: 1.0)
//        zeroRect.origin.x -= 2
//        oneRect.origin.x += 2
//        let currentX = zeroRect.origin.x + (oneRect.origin.x - zeroRect.origin.x) * CGFloat(value)
//        oneRect.origin.x = currentX
//
//        let r = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
//
//        var labelRect: CGRect = .zero
//        labelRect.origin.y = r.origin.y - rowSpacing - labelSize.height
//        let center = CGPoint(x: r.minX + r.width / 2, y: r.minY + r.height / 2)
//        labelRect.size = labelSize
//        valueLabel.backgroundColor = UIColor.white.withAlphaComponent(0.9)
//        valueLabel.frame = labelRect
//        valueLabel.center.x = center.x
//        let intValue: Int = Int(value * 100)
//
//        print("intValue : \(intValue)")
//        if !isValueDirectEnable {
//            valueLabel.text = String.init(format: "%d", intValue)
//        }
//
//        lastRect = oneRect
//
//        return oneRect
//    }
    
}
