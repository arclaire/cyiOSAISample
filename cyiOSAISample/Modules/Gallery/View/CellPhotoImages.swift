//
//  CellPhotoImages.swift
//  PicsMate
//
//  Created by Lucy on 07/01/20.
//  Copyright © 2020 PT. DEEPINDO TECHNOLOGY INDONESIA. All rights reserved.
//

import UIKit

class CellPhotoImages: UICollectionViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var consTopDistance: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.prepareUI()
    }

    private func prepareUI() {
        
        self.viewContainer.clipsToBounds = true
        self.image.layer.cornerRadius = 10.0
        self.consTopDistance.constant = 5
    }
    
    func setImage(img: UIImage) {
        self.image.image = img
    }
    
}

