//
//  ALRouterCamera.swift
//  cyiOSAISample
//
//  Created by Lucy on 14/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

class ALRouterCamera: Router {
    func create() {
        
    }
    
    
    let navigationController: UINavigationController?
    
    init(nav: UINavigationController) {
        self.navigationController = nav
    }
    
    func create(cameraType: CameraType,
                ads: AdverstiseStatus,
                modelArtSelected: ALArtModel? = nil) {
        let vc = ALCameraViewController(cameraType: cameraType)
        vc.modelArtSelected = modelArtSelected
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
   
}
