//
//  SDArtModel.swift
//  cyiOSAISample
//
//  Created by Michael on 08/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

class SDAnimeRequirements: NSObject {
    var maxDimension: CGFloat = 0.0
    var minDimension: CGFloat = 0.0
    var minRatio: CGFloat = 0.0
    var maxRatio: CGFloat = 0.0
}

class ALArtModel: NSObject {
    var key: String = ""
    var image: String = ""
    var lookup: String = ""
    var isvip : Bool = true
    var previewImage: UIImage?
    var animeRequirements: SDAnimeRequirements = SDAnimeRequirements()
    var apiParams: [String: Any]!
    var selected: Bool = false
}

extension ALArtModel {
    class func initialize() -> [ALArtModel]? {
        var artModels: [ALArtModel] = []
        
        let path = SDFileController.getMainBundle("Arts", resourceName: "Arts", type: "plist")
        print("PATHS: ", path)
        if let arts = NSArray(contentsOf: URL(fileURLWithPath: path)) {
            for art in arts {
                if case let Key as String = (art as! NSDictionary).value(forKey: "Key"),
                    case let Image as String = (art as! NSDictionary).value(forKey: "Image"),
                    case let IsVip as Bool = (art as! NSDictionary).value(forKey: "IsVip") {
                    let artModel: ALArtModel = ALArtModel()
                    artModel.key = Key
                    artModel.image = Image
                    
                    if case let Lookup as String = (art as! NSDictionary).value(forKey: "Lookup") {
                        artModel.lookup = Lookup
                    }
                    
                    if case let params as [String : Any] = (art as! NSDictionary).value(forKey: "apiParams") {
                        artModel.apiParams = params
                    }
                    
                    
                    artModel.isvip = IsVip
                    
                    var previewPath = "Preview".stringByAppendingPathComponent(path: artModel.image)
                    previewPath = SDFileController.getMainBundle("Arts", resourceName: previewPath, type: "png")
                    artModel.previewImage = UIImage.init(contentsOfFile: previewPath)
                    
                    artModels.append(artModel)
                }
            }
        }
        
        
        
        return artModels
    }
    
    class func getLookupArt(_ lookup: String, image: UIImage, completeHandler: (UIImage?) -> Void) {
        var lookupPath = "Lookup".stringByAppendingPathComponent(path: lookup)
        lookupPath = SDFileController.getMainBundle("Arts", resourceName: lookupPath, type: "pie")
        
        SDOilPaintManager.apply(originalImage: image.resetPixelArtisticFilterOriginalImage(), filePathOfPie: lookupPath) { (image) in
            completeHandler(image)
        }
    }
}
