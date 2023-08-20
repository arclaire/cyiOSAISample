//
//  SDAnimeModel.swift
//  cyiOSAISample
//
//  Created by Michael on 27/03/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

class SDAnimeModel: NSObject {
    var Key: String = ""
    var IsVip : Bool = true
    var PreviewImage: UIImage?
    var Selected: Bool = false
}

extension SDAnimeModel {
    class func initialize() -> [SDAnimeModel]? {
        var animeModels: [SDAnimeModel] = []
        
        let path = SDFileController.getMainBundle("Anime", resourceName: "Anime", type: "plist")
        if let animes = NSArray(contentsOf: URL(fileURLWithPath: path)) {
            for anime in animes {
                if let Key = (anime as! NSDictionary).value(forKey: "Key") as? String,
                    let IsVip = (anime as! NSDictionary).value(forKey: "IsVip") as? Bool,
                    let PreviewImage = (anime as! NSDictionary).value(forKey: "PreviewImage") as? String {
                    let animeModel: SDAnimeModel = SDAnimeModel()
                    animeModel.Key = Key
                    animeModel.IsVip = IsVip
                    
                    var previewPath = "Preview".stringByAppendingPathComponent(path: PreviewImage)
                    previewPath = SDFileController.getMainBundle("Anime", resourceName: previewPath, type: "png")
                    animeModel.PreviewImage = UIImage.init(contentsOfFile: previewPath)
                    
                    animeModels.append(animeModel)
                }
            }
        }
        
        return animeModels
    }
    
    class func getLookupArt(_ lookup: String, image: UIImage, completeHandler: (UIImage?) -> Void) {
        var lookupPath = "Lookup".stringByAppendingPathComponent(path: lookup)
        lookupPath = SDFileController.getMainBundle("Arts", resourceName: lookupPath, type: "pie")
        
        SDOilPaintManager.apply(originalImage: image.resetPixelArtisticFilterOriginalImage(), filePathOfPie: lookupPath) { (image) in
            completeHandler(image)
        }
    }
}
