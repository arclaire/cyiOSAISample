//
//  CellPhotoAlbum.swift
//  PicsMate
//
//  Created by Lucy on 07/01/20.
//  Copyright © 2020 PT. DEEPINDO TECHNOLOGY INDONESIA. All rights reserved.
//

import UIKit

class CellPhotoAlbum: UITableViewCell {

    @IBOutlet weak var imageThumbnails: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
