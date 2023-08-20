//
//  ALRouterGallery.swift
//  cyiOSAISample
//
//  Created by Lucy on 14/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation


class ALRouterGallery: Router {
    func create() {
        
    }
    
    
    let navigationController: UINavigationController?
    
    init(nav: UINavigationController) {
        self.navigationController = nav
    }
    
    func create(cameraType: CameraType,
                ads: AdverstiseStatus,
                isFromCamera: Bool,
                modelArtSelected: ALArtModel?=nil ) {
        let vc = ALGalleryViewController()
        vc.advStatus = ads
        vc.isFromCamera = isFromCamera
        vc.cameraType = cameraType
        vc.modelArtSelected = modelArtSelected
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
   
}
