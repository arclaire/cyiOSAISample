//
//  ModelError.swift
//  WeatherCy
//
//  Created by Lucy on 21/08/20.
//  Copyright © 2020 Lucy. All rights reserved.
//

import Foundation


struct ModelArrayErrors: Codable, Error {
    var errors: [ModelError]?
    
    enum CodingKeys: String, CodingKey {
        case errors = "errors"
    }
}

struct ModelError: Codable, Error {
    var title: String?
    var detail: String?
    var errorImageUrl: String?
    var status: NSNumber?

    enum CodingKeys: String, CodingKey {
        case title
        case detail
    }
}


extension ModelError {
    init(systemError: NSError) {
        self.init()
        self.status = systemError.code as NSNumber

        if systemError.code == NSURLErrorNotConnectedToInternet ||
            systemError.code == NSURLErrorNetworkConnectionLost  {
            
            self.title = "title"
            self.detail = "no connection"
        } else {
            self.title = systemError.localizedDescription
            self.detail = systemError.localizedRecoverySuggestion
        }
    }
}
