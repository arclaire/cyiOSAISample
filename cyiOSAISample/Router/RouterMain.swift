//
//  RouterMain.swift
//  cyiOSAISample
//
//  Created by Lucy on 13/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

import UIKit

protocol Router {
    func create()
    func routeTo(route: Router)
}

extension Router {
    func routeTo(route: Router) {
        route.create()
    }
}
