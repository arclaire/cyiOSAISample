//
//  SDEffectsModel.swift
//  cyiOSAISample
//
//  Created by Lucy on 05/12/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

@objc public enum EffectsCategory: Int {
    case none
    case drawn
    case lens
    case routine
}

extension EffectsCategory {
    func effectsCategory(filter category: EffectsCategory) -> String {
        switch category {
            
        case .drawn:
            return "Drawn"
            
        case .lens:
            return "Lens"
            
        case .routine:
            return "Routine"
            
        default:
            return ""
        }
    }
}


class SDEffectsModel: NSObject {
    var category: EffectsCategory = .none
    var name: String = ""
    var effectsItems: [SDEffectsItem] = []
    var selected: Bool = false
}

class SDEffectsItem: NSObject {
    var Category: EffectsCategory = .none
    var Key: String = ""
    var Name: String = ""
    var PreviewImage: String = ""
    var Lookup: String = ""
    var IsVip: Bool = false
    var FloatParameter: CGFloat = -1.0
    var FloatCurrentSliderValue: CGFloat = -1.0
    var Selected: Bool = false
}

extension SDEffectsModel {
    class func gainEffectsCategoryWithEffectsModuleName(module name: String) -> EffectsCategory {
        if name == "Drawn" {
            return .drawn
            
        } else if name == "Lens" {
            return .lens
            
        } else if name == "Routine" {
            return .routine
            
        }
        return .none
    }
    
}

extension SDEffectsModel {
    class func initializerBuiltInFilters() -> [SDEffectsModel]? {
        var effectsModels: [SDEffectsModel] = []
        
        let path = SDFileController.getMainBundle("EffectsCategory", resourceName: "EffectsCategory", type: "plist")
        let filterDic = NSDictionary(contentsOf: URL(fileURLWithPath: path))
        
        let allKeys = filterDic?.allKeys
        if allKeys == nil { return nil }
        
        for category in allKeys! {
            let effectsModel: SDEffectsModel = SDEffectsModel()
            
            autoreleasepool {
                if let nameBundle = category as? String {
                    effectsModel.name = nameBundle
                    effectsModel.category = gainEffectsCategoryWithEffectsModuleName(module: effectsModel.name)
                    let items = filterDic?.object(forKey: nameBundle)
                    
                    if let itemns = items as? Array<Any> {
                        
                        for i in 0..<itemns.count {
                            
                            autoreleasepool {
                                let itemEffects = itemns[i]
                                
                                if let effectsItem = SDEffectsItem.initializerEffectsItem(bundle: nameBundle, effects: itemEffects) {
                                    effectsItem.Category = effectsModel.category
                                    effectsModel.effectsItems.append(effectsItem)
                                }
                            }
                        }
                    }
                }
            }
            
            effectsModels.append(effectsModel)
        }
        
        return effectsModels.sorted(by: {$0.name < $1.name})
    }
}

extension SDEffectsItem {
    class func initializerEffectsItem(bundle name: String, effects paramter: Any) -> SDEffectsItem? {
        if let paramterDic = paramter as? NSDictionary {
            let effectsItem = SDEffectsItem()
            
            let effectsPathBundle = Bundle.main.path(forResource: name, ofType: "bundle")!
            
            if let name = paramterDic.object(forKey: "Name") {
                effectsItem.Name = "\(name)"
                
                effectsItem.PreviewImage = effectsPathBundle.stringByAppendingPathComponent(path: "/Preview/" + effectsItem.Name + ".png")
                
                if let IsVip = paramterDic.object(forKey: "IsVip") as? Bool {
                    effectsItem.IsVip = IsVip
                }
                
                if let lookup = paramterDic.object(forKey: "Lookup") as? String {
                    effectsItem.Lookup = lookup
                }
                
                if let key = paramterDic.object(forKey: "Key") as? String {
                    effectsItem.Key = key
                }
                
                return effectsItem
                
            } else {
                return nil
            }
            
        }
        
        return nil
    }
    
    func resetValueSlider() {
        self.FloatCurrentSliderValue = -1.0
        self.FloatParameter = -1.0
    }
}
