//
//  TableHeaderView.swift
//  WeatherCy
//
//  Created by Lucy on 21/08/20.
//  Copyright © 2020 Lucy. All rights reserved.
//

import UIKit

final class TableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var labelTitle: UILabel!
    
    static let reuseIdentifier: String = String(describing: self)

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    

}
