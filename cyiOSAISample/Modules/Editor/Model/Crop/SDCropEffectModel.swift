//
//  SDCropEffectModel.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/14.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

class SDCropItem: NSObject {
    var title: String = ""
    var image: UIImage? = UIImage()
    var selectedImage: UIImage? = UIImage()
    var isSelected: Bool = false
    
    init(title: String, image: UIImage?, selectedImage: UIImage?) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
    }
}

@objc public enum SDCropEffectModel: Int {
    case free
    case ratio1_1
    case ratio4_5
    case ratio3_4
    case ratio4_3
    case ratio16_9
    case ratio9_16
    case ratio3_2
    case ratio2_3
    
    func toString() -> String {
        switch self {
        case .free:
            return "free"
        case .ratio1_1:
            return "1:1"
        case .ratio4_5:
            return "4:5"
        case .ratio3_4:
            return "3:4"
        case .ratio4_3:
            return "4:3"
        case .ratio16_9:
            return "16:9"
        case .ratio9_16:
           return "9:16"
        case .ratio3_2:
            return "3:2"
        case .ratio2_3:
            return "2:3"
        }
    }
    
    func toRatio() -> CGFloat {
        switch self {
        case .free:
            return 0.cgFloat
        case .ratio1_1:
            return 1.0/1
        case .ratio4_5:
            return 5.0/4
        case .ratio3_4:
            return 4.0/3
        case .ratio4_3:
            return 3.0/4
        case .ratio16_9:
            return 9.0/16
        case .ratio9_16:
            return 16.0/9
        case .ratio3_2:
            return 2.0/3.0
        case .ratio2_3:
            return 3.0/2.0
        }
    }
    
    static func crop(row: Int) -> SDCropEffectModel {
        if row == 0 {
            return .free
        } else if row == 1 {
            return .ratio1_1
        } else if row == 2 {
            return .ratio4_5
        } else if row == 3 {
            return .ratio3_4
        } else if row == 4 {
            return .ratio4_3
        } else if row == 5 {
            return .ratio16_9
        } else if row == 6 {
            return .ratio9_16
        } else if row == 7 {
            return .ratio3_2
        } else if row == 8 {
            return .ratio2_3
        }
        return .free
    }
}
