//
//  SDUndoOperator.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/26.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

public protocol UndoOperator {
    func undo()
    func redo()
    func clearRedoStack()
    
    //func usedTimes() -> Int
}


// MARK: -

extension NSNotification.Name {
    public static let UIEffectIntensityNotification: NSNotification.Name = NSNotification.Name(rawValue: "UIEffectIntensityNotification")
}

extension NSNotification {
    struct Key {
        struct ImageEditor {
            public static let FundationId = "com.ios.sotacam.notification.key.imageeditor.fundationid"
            public static let Intensity = "com.ios.sotacam.notification.key.imageeditor.intensity"
        }
        
        
    }
}

public class IntensityEffectWrapper: UndoOperator {
    
    struct IntensityItem {
        var fromValue: CGFloat
        var toValue: CGFloat
    }
    
    var items:[IntensityItem] = []
    var cacheItems:[IntensityItem] = []
    
    var targetFilter: SDIntensityFilterProtocol
    var fundationID: Int
    
    init(fundationId: Int, targetFilter: SDIntensityFilterProtocol) {
        self.fundationID = fundationId
        self.targetFilter = targetFilter
    }
    
    
    public func undo() {
        if !items.isEmpty {
            let item = items.popLast()!
            cacheItems.append(item)
            targetFilter.setIntensity(item.fromValue)
            targetFilter.renderFrame()
            NotificationCenter.default.post(name: .UIEffectIntensityNotification, object: targetFilter, userInfo: [NSNotification.Key.ImageEditor.Intensity: item.fromValue, NSNotification.Key.ImageEditor.FundationId: fundationID])
            
        }
        
    }
    
    public func redo() {
        if !cacheItems.isEmpty {
            let item = cacheItems.popLast()!
            items.append(item)
            targetFilter.setIntensity(item.toValue)
            targetFilter.renderFrame()
            NotificationCenter.default.post(name: .UIEffectIntensityNotification, object: targetFilter, userInfo: [NSNotification.Key.ImageEditor.Intensity: item.toValue, NSNotification.Key.ImageEditor.FundationId: fundationID])
        }
        
    }
    
    public func clearRedoStack() {
        cacheItems.removeAll()
    }
    
    func appendItem(fromValue: CGFloat, toValue: CGFloat) {
        items.append(IntensityItem(fromValue: fromValue, toValue: toValue))
        clearRedoStack()
    }
    
}


