//
//  SDBundle_Extensions.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/4.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

extension Bundle {
    func mapLookupToPreviewInFilterModule() -> NSDictionary? {
        let filterName = "FilterCategory"
        let plistPath = Bundle.main.path(forResource: "\(filterName)", ofType: "bundle")
        
        guard let plisPath = plistPath else { return nil}
        let filterPlistPath = plisPath.stringByAppendingPathComponent(path: "\(filterName).plist")
        
        if let plistDictionary: NSDictionary = NSDictionary(contentsOfFile: filterPlistPath) {
            return plistDictionary
        }
        
        return nil
    }
}
