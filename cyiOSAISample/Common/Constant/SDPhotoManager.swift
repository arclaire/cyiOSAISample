//
//  SDPhotoManager.swift
//  cyiOSAISample
//
//  Created by Lucy on 12/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

import Foundation
import Photos

class SDPhotoManager {
    static let sharedInstance = SDPhotoManager()
}

extension SDPhotoManager {
    func saveImageIntoAlbum(image: UIImage, complation: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (result, error) in
            complation(result, error)
        }
    }
}

extension SDPhotoManager {
    func thumbForPhotoAsset(asset: PHAsset, desireSize size: CGSize, targetImage: @escaping (UIImage?) -> Void) {
        let imageReqOptions = PHImageRequestOptions()
        imageReqOptions.isSynchronous = false
        imageReqOptions.isNetworkAccessAllowed = true
        imageReqOptions.resizeMode = .exact
        imageReqOptions.deliveryMode = .highQualityFormat
        
        let scale = UIScreen.main.scale
        let sizeInScreen = CGSize(width: size.width * scale, height: size.height * scale)
        
        PHImageManager.default().requestImage(for: asset, targetSize: sizeInScreen, contentMode: PHImageContentMode.aspectFill, options: imageReqOptions) { (image, nil) in
            targetImage(image)
        }
    }
}

extension SDPhotoManager {
    func latestPhotoAsset(photoAsset: @escaping (_ asset: PHAsset?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate.init(format: "mediaType == 1")
        fetchOptions.sortDescriptors = [NSSortDescriptor.init(key: "modificationDate", ascending: false)]
        
        let fetchResults = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let leatestAsset = fetchResults.firstObject
        
        if leatestAsset != nil {
            photoAsset(leatestAsset)
        } else {
            photoAsset(nil)
        }
    }
}

extension SDPhotoManager {
    func authoring(result: @escaping (_ status: Bool) -> Void) {
        if denied() {
            result(false)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            let authorized = status == .authorized
            result(authorized)
        }
    }
}

extension SDPhotoManager {
    private func authorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    private func denied() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .denied
    }
}
