//
//  ALRouterEditor.swift
//  cyiOSAISample
//
//  Created by Lucy on 14/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation


public enum SDImageEditFundation: Int {
    case main = 10086
    case crop
    case adjust
    case artfilter
    case effect

    
    func instanceFunctionController(imageEditorContainer: ALImageEditorContaionerProtocol) -> ALFundationControllerProtocol {
        switch self {
        case .main:
            return ALMainPageEditorFundationController(imageEditContainer: imageEditorContainer)
            
        case .crop:
            return ALCropPageEditorFundationController(imageEditContainer: imageEditorContainer)
        
        case .adjust:
            return ALAdjustPageEditorFundationController(imageEditContainer: imageEditorContainer)
            
        case .artfilter:
            return ALArtFilterPageFundationEditorController(imageEditContainer: imageEditorContainer)
            
        case .effect:
            return SDEffectsPageFundationEditorController(imageEditContainer: imageEditorContainer)
            
        }
    }
}


class ALRouterEditor: Router {
    func create() {
        
    }
    
    
    let navigationController: UINavigationController?
    
    init(nav: UINavigationController) {
        self.navigationController = nav
    }
    
    func create(image: UIImage,
                ads: AdverstiseStatus,
                modelArtSelected: ALArtModel? = nil) {
        let vc = ALEditorViewController(originalImage: image, compressedImage: image)
        vc.initialFundation = .artfilter
        vc.modelArt = modelArtSelected
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
   
}
