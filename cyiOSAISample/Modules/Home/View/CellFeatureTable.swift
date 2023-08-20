//
//  CellFeatureTable.swift
//  cyiOSAISample
//
//  Created by Lucy on 15/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class CellFeatureTable: UITableViewCell {
   
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
