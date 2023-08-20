//
//  Constants.swift
//  WeatherCy
//
//  Created by Lucy on 20/08/20.
//  Copyright © 2020 Lucy. All rights reserved.
//

import Foundation

let API_KEY = "025f20a6a9c8f35bbe62d8a9f9b8897d"

let ID_VC_ListHeroes          = "VCListHeroes"
let ID_VC_ListHeroesDetail    = "VCListHeroesDetail"

import Foundation
import UIKit

struct SDConstants {
    
    // Constans in UI
    struct UI {
        
        //
        static let Screen_Scale = UIScreen.main.scale
        
        //Adjust UI
        static let Screen_Statusbar_Add_Height = (Is_Iphone && Is_Iphone_XR) ? 0 : 24.cgFloat
        static let Screen_Statusbar_Height = (Is_Iphone && Is_Iphone_XR) ? 44.cgFloat : 24.cgFloat
        static let Screen_Bottom = (Is_Iphone && Is_Iphone_XR) ? 34.cgFloat : 0.cgFloat
        static let Screen_Safe_Bangs = (Is_Iphone && Is_Iphone_XR) ? 44.cgFloat : 0.cgFloat
        
        static let Screen_Bounds = UIScreen.main.bounds
        static let Screen_Width =  UIScreen.main.bounds.width
        static let Screen_Height = UIScreen.main.bounds.height
        static let Screen_Max_Length = max(Screen_Width, Screen_Height)
        
        //Bool
        static let Is_Iphone = UIDevice.current.userInterfaceIdiom == .phone ? true : false
        static let Is_Ipad = UIDevice.current.userInterfaceIdiom == .pad ? true : false
        
        //Mobile phone models
        static let Is_Iphone_4_Or_Less = (Is_Iphone && Screen_Max_Length < 568.0)
        static let Is_Iphone_5 = (Is_Iphone && Screen_Max_Length == 568.0)  //320 * 480  4.0inch
        static let Is_Iphone_6 = (Is_Iphone && Screen_Max_Length == 667.0)  //375 * 667  4.7inch
        static let Is_Iphone_6P = (Is_Iphone && Screen_Max_Length == 736.0) //414 * 736  5.5inch
        static let Is_Iphone_X = (Is_Iphone && Screen_Max_Length == 812.0)  //375 * 812  5.8inch iphone X,XS
        static let Is_Iphone_XR = (Is_Iphone && Screen_Max_Length == 896.0) //414 * 896  6.5inch iphone xs_max
        
    }
    
    struct IMAGE {
        static let compressedMaxLength = Int(0.5 * 1024 * 1024)
        static let desireDimension: CGFloat = 2000
    }
    
    struct S3 {
        #if DEBUG
        static let BaseURL = ""
        #else
        static let BaseURL = ""
        #endif
        
        static let BaseDevURL = ""
        static let BaseProdURL = ""
        static let AliyunBaseDevURL = ""
    }
}
