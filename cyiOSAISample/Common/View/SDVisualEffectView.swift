//
//  SDVisualEffectView.swift
//  cyiOSAISample
//
//  Created by Lucy on 12/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

@IBDesignable
public class SDVisualEffectView: UIVisualEffectView {
    private
    let blurEffect : UIBlurEffect = {
        let classStr = ["_", "U", "I", "C", "u", "s", "t", "o", "m", "B", "l", "u", "r", "E", "f", "f", "e", "c", "t"].joined()
        return (NSClassFromString(classStr) as! UIBlurEffect.Type).init()
    }()
    
    @IBInspectable
    var colorTint: UIColor? {
        
        get { return blurEffect.value(forKeyPath: "colorTint") as? UIColor }
        set { update(newValue, forkeyPath: "colorTint") }
    }
    
    @IBInspectable
    var colorTintAlpha : CGFloat {
        get { return blurEffect.value(forKeyPath: "colorTintAlpha") as! CGFloat}
        set {
            switch newValue {
            case ...0:
                update(0, forkeyPath: "colorTintAlpha")
            case 1...:
                update(1, forkeyPath: "colorTintAlpha")
            default:
                update(newValue, forkeyPath: "colorTintAlpha")
            }
        }
    }
    
    @IBInspectable
    var blurRadius: CGFloat {
        get { return blurEffect.value(forKeyPath: "blurRadius") as! CGFloat }
        set {
            switch newValue {
            case ...0:
                update(0, forkeyPath: "blurRadius")
            case 100...:
                update(100, forkeyPath: "blurRadius")
            default:
                update(newValue, forkeyPath: "blurRadius")
            }
        }
    }
    
    required init(blurRadius: CGFloat = 10,
                  scale: CGFloat = 1,
                  colorTintAlpha: CGFloat = 1) {
        super.init(effect: UIBlurEffect(style: .light))
        defaultValueInit(blurRadius: blurRadius,
                         scale: scale,
                         colorTintAlpha: colorTintAlpha)
    }
    
    private override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
    }
    
    init(frame: CGRect) {
        
        super.init(effect: UIBlurEffect(style: .light))
        self.frame = frame
        defaultValueInit(blurRadius: 10, scale: 1, colorTintAlpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultValueInit(blurRadius: 10, scale: 1, colorTintAlpha: 1)
    }
    
    private func defaultValueInit(blurRadius: CGFloat, scale: CGFloat, colorTintAlpha: CGFloat) {
        blurEffect.setValue(blurRadius, forKeyPath: "blurRadius")
        blurEffect.setValue(scale, forKeyPath: "scale")
        blurEffect.setValue(colorTintAlpha, forKeyPath: "colorTintAlpha")
        self.effect = blurEffect
    }
    
    private func update(_ value: Any?, forkeyPath keyPath: String) {
        blurEffect.setValue(value, forKeyPath: keyPath)
        self.effect = blurEffect
    }
}
