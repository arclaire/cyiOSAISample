//
//  CollectionView+Extensions.swift
//  cyiOSAISample
//
//  Created by Michael on 29/05/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

extension UICollectionView {
    
    func isValid(indexPath: IndexPath) -> Bool {
        guard indexPath.section < numberOfSections,
              indexPath.row < numberOfItems(inSection: indexPath.section)
            else { return false }
        return true
    }
    
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }) { _ in
            completion()
        }
    }

}
