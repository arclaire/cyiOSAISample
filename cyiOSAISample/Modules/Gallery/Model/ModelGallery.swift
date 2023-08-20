//
//  ModelGallery.swift
//  PicsMate
//
//  Created by Lucy on 07/01/20.
//  Copyright © 2020 PT. DEEPINDO TECHNOLOGY INDONESIA. All rights reserved.
//

import Foundation
import Photos

class ModelAlbums {
    
    var strTitle: String = ""
    var imageCover: UIImage = UIImage()
    var intCount: Int = 0
    var arrImages: [UIImage] = [UIImage]()
    var asset: PHAssetCollection = PHAssetCollection() {
        didSet {
            self.strTitle = self.asset.localizedTitle ?? "unknown"
            self.imageCover = self.asset.getCoverImgWithSize(CGSize(width: 106, height: 150))
            self.intCount = self.asset.totalAssets()
        }
    }
    
}

extension PHPhotoLibrary {
    // MARK: - Public methods
    static func checkAuthorizationStatus(completion: @escaping (_ status: PHAuthorizationStatus) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            completion(.authorized)
        } else {
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined {
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == PHAuthorizationStatus.authorized {
                        completion(.authorized)
                    } else {
                        completion(.restricted)
                    }
                })
            } else {
                completion(.denied)
            }
        }
    }
}

extension PHAssetCollection {
    // MARK: - Public methods
    func getCoverImgWithSize(_ size: CGSize) -> UIImage! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let assets = PHAsset.fetchAssets(in: self, options: fetchOptions)
        
        let asset = assets.lastObject
        if let image = asset?.getAssetThumbnail(size: size) {
            return image
        } else {
            return UIImage()
        }
    }
    
    func hasAssetsImages() -> Bool {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let assets = PHAsset.fetchAssets(in: self, options: fetchOptions)
        
        return assets.count > 0
    }
    
    func totalAssets() -> Int {
        let assets = PHAsset.fetchAssets(in: self, options: nil)
        return assets.count
    }
}

extension PHAsset {
    
    // MARK: - Public methods
    
    func getAssetThumbnail(size: CGSize) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        option.deliveryMode = .opportunistic
        manager.requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            if let img = result {
                thumbnail = img
            }
            
        })
        
        return thumbnail
    }
    
    func getOrginalImage(completion:@escaping (UIImage) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option, resultHandler: {(result, info)->Void in
            image = result!
            
            completion(image)
        })
    }
    
    func getImageFromPHAsset(retrievedImage: @escaping(_ image:UIImage, _ msg:String) -> Void) {
        var image = UIImage()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        autoreleasepool{
            if (self.mediaType == PHAssetMediaType.image) {
                PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions, resultHandler: { (pickedImage, info) in
                    if let img = pickedImage {
                        retrievedImage(img, "success")
                    } else {
                        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
                        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                        requestOptions.isSynchronous = false
                        requestOptions.isNetworkAccessAllowed = true
                        PHCachingImageManager.default().requestImageData(for: self, options: requestOptions) { (imageData, imageUTI, orientation, info) in
                            guard let img = imageData else {
                                if let error = info?[PHImageErrorKey] as? NSError {
                                    PCAppController.sharedInstance.showToast(message: error.localizedDescription)
                                }
                                retrievedImage(UIImage(), "failed")
                                return
                            }
                            let degraded = info?[PHImageResultIsDegradedKey] as? NSNumber
                            
                            if degraded != nil && !degraded!.boolValue {
                                image = UIImage(data: img)!
                                retrievedImage(image, "success")
                            }
                        }
                    }
                    
                })
            }
        }
    }
    
}
