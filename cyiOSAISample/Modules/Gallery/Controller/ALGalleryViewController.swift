//
//  PCGalleryViewController.swift
//  PicsMate
//
//  Created by admin on 2019/12/10.
//  Copyright © 2019 PT. DEEPINDO TECHNOLOGY INDONESIA. All rights reserved.
//

import UIKit
import Photos

enum AdverstiseStatus {
    case none
    case planC
}

protocol ALGalleryVCDelegate: NSObject {
    func galleryDidFinishSelectImage(image: UIImage)
}

class ALGalleryViewController: UIViewController {
    @IBOutlet weak var labelNavigation: UILabel!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewOverlayTable: UIView!
    @IBOutlet weak var viewContainerLabel: UIView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonCamera: UIButton!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imgIconCamera: UIImageView!
    @IBOutlet weak var imgIconClose: UIImageView!
    @IBOutlet weak var imgIconArrow: UIImageView!
    @IBOutlet weak var viewContainerButton: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var consViewOverLaytableBotToViewContainerButton: NSLayoutConstraint!
    
    @IBOutlet weak var consViewOverlay: NSLayoutConstraint!
    @IBOutlet weak var flowlayout: UICollectionViewFlowLayout!
    @IBOutlet weak var buttonAlbum: UIButton!
    
    var modelAlbum: [ModelAlbums] = []
    var modelArtSelected: ALArtModel?
    weak var delegate: ALGalleryVCDelegate?
    var selectedAlbum: ModelAlbums?
    private var photos: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    
    var isFromCamera: Bool = false
    var arrayOfImage: [UIImage] = []
    var isFirstLoad: Bool = true
    var featureKey: String?
    var filterKey: String?
    var cameraType: CameraType = .art
    
    var isSubscription: Bool = false
    private var isFromPreviousVC: Bool = false
    
    var advStatus: AdverstiseStatus = .none
    
    
    private var isDetectingFace: Bool = false
    private var isDownloadingAsset: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
        self.consViewOverLaytableBotToViewContainerButton.constant = -self.consViewOverlay.constant
        self.setupTableView()
        self.setUpCollectionView()
        self.prepareUI()
        self.checkAutorizationStatus()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.tableview.separatorStyle = .none
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ALUtils.lockOrientation(.portrait)
        self.checkAutorizationStatus()
        
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func prepareUI() {
        self.viewContainerButton.backgroundColor = UIColor.white
        self.viewContainerLabel.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor.white
        self.tableview.backgroundColor = UIColor.white
        self.viewOverlayTable.backgroundColor = UIColor.clear
        self.tableview.layer.cornerRadius = 10
        self.tableview.layer.masksToBounds = true
        self.viewNavigation.layer.applyRoundedShadow(color: UIColor.lightGray, alpha: 0.5, x: 0, y: 2, blur: 5, spread: 1)
        self.viewContainerButton.layer.applyRoundedShadow(color: UIColor.gray, alpha: 1, x: 0, y: 2, blur: 5, spread: 1)
        self.labelNavigation.textColor = UIColor.black
        self.viewNavigation.backgroundColor = UIColor.white
        self.labelNavigation.text = "title_navigation_galery".localized
        self.viewOverlayTable.layer.cornerRadius = 10
        self.viewOverlayTable.clipsToBounds = true
        //self.viewOverlayTable.layer.applyRoundedShadow(color: UIColor.gray, alpha: 1, x: 0, y: 2, blur: 5, spread: 1)
        self.labelTitle.text = ""
        self.labelTitle.textColor = UIColor.black
    }
    
    private func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func openCameraVC() {
        self.loadCamera()
    }
    
    func loadCamera() {
        if let nav = self.navigationController {
            let router: ALRouterCamera = ALRouterCamera(nav: nav)
            router.create(cameraType: self.cameraType, ads: .none, modelArtSelected: self.modelArtSelected)
        } else {
            
        }
    }
    
    func openEditor(ads: AdverstiseStatus, image: UIImage) {
        if let nav = self.navigationController {
            if self.cameraType == .art {
                let router: ALRouterEditor = ALRouterEditor(nav: nav)
                router.create(image: image, ads: ads, modelArtSelected: self.modelArtSelected)
               
            } else if self.cameraType == .aging {
                
                
            } else if self.cameraType == .machineLearning {
                let vc = CoreMLViewController()
                vc.imagePassed = image
                nav.pushViewController(vc, animated: true)
                
            }
           
        } else {
            
        }
    }
    
    private func setUpCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = true
        self.flowlayout.minimumInteritemSpacing = 5
        self.collectionView.contentInset = UIEdgeInsets(top: 15, left: 5, bottom: 60, right: 5)
        self.collectionView.backgroundView?.backgroundColor = .white
        self.collectionView.backgroundColor = .white
        let nib = UINib(nibName: String(describing: CellPhotoImages.self), bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: String(describing: CellPhotoImages.self))
        
    }
    
    private func setupTableView() {
        let nibToRegister = UINib(nibName: String(describing: CellPhotoAlbum.self), bundle: nil)
        self.tableview.register(nibToRegister, forCellReuseIdentifier: String(describing: CellPhotoAlbum.self))
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        
    }
    
    private func setUIState() {
        if self.modelAlbum.count > 0 {
            self.tableview.reloadData()
            if let album = self.selectedAlbum {
                let albumActive =  album
                self.labelTitle.text = albumActive.strTitle
            } else {
                let albumActive = self.modelAlbum.first
                self.labelTitle.text = albumActive?.strTitle
            }
        }
    }
    
    func showListAlbum(ishidden: Bool) {
        var constant = -consViewOverlay.constant
        var floatDegree: CGFloat = 0
        if !ishidden {
            constant = 0
            floatDegree = CGFloat(1 * Double.pi)
        }
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: [],
                       animations: {
            self.imgIconArrow.transform = CGAffineTransform(rotationAngle: floatDegree)
            self.consViewOverLaytableBotToViewContainerButton.constant =  constant
            self.viewOverlayTable.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @IBAction func action(_ sender: Any) {
        if let btn = sender as? UIButton {
            if btn == self.buttonClose {
                self.popViewController()
            }
            
            if btn == self.buttonCamera {
                if self.isFromCamera {
                    self.popViewController()
                } else {
                    self.openCameraVC()
                }
            }
            
            if btn == self.buttonAlbum {
                if self.consViewOverLaytableBotToViewContainerButton.constant == 0 {
                    self.showListAlbum(ishidden: true)
                } else {
                    self.showListAlbum(ishidden: false)
                }
                
            }
        }
    }
}

extension ALGalleryViewController {
    func setSubscriptionFalse(){
        self.isSubscription = false
        setButtonCloseVisibility(isVisible: true)
    }
}

extension ALGalleryViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.checkAutorizationStatus()
        }
        
    }
}

//MARK: - COLLECTIONVIEW DELEGATE
extension ALGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var intTotal = 0
        if self.photos.count > 0 {
            intTotal = self.photos.count
        }
        return intTotal
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CellPhotoImages.self), for: indexPath) as! CellPhotoImages
        if self.photos.count > 0 {
            let asset = self.photos[indexPath.row]
            let width = UIScreen.main.bounds.size.width / 3 - 15
            let height = width/105 * 150
            cell.image.image = asset.getAssetThumbnail(size: CGSize(width: width, height: height))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width / 3 - 15
        let height = width/105 * 150
        let size = CGSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !self.isDetectingFace && !self.isDownloadingAsset {
            self.isDownloadingAsset = true
            self.isFromPreviousVC = true
            self.showListAlbum(ishidden: true)
            let photo = self.photos[indexPath.row]
            
            photo.getImageFromPHAsset(retrievedImage: {
                (image, msg) -> Void in
                if msg == "success" {
                    let size = CGSize(width: photo.pixelWidth, height: photo.pixelHeight)
                    self.processesRetrievedImage(img: image, oriSize: size)
                } else {
                    self.isDownloadingAsset = false
                }
            })
        }
    }
    
    func processesRetrievedImage(img: UIImage, oriSize: CGSize) {
        
        if let sampleImg = img.resizeWithScaleAspectFitMode(to: SDConstants.IMAGE.desireDimension) {
            let artClipImage = sampleImg.resetPixelArtisticFilterOriginalImage()
            self.isDownloadingAsset = false
            self.isDetectingFace = false
            self.openEditor(ads: .none, image: artClipImage)
        }
        
    }
}

//MARK: - TABLEVIEW DELEGATE
extension ALGalleryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.modelAlbum.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CellPhotoAlbum.self)) as? CellPhotoAlbum {
            
            if self.modelAlbum.count > indexPath.row {
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                let album = self.modelAlbum[indexPath.row]
                cell.imageThumbnails.image = album.imageCover
                let arrAttribute1 = [
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    //NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 15)
                ]
                
                let arrAttribute2 = [
                    NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                    //NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 14)
                ]
                
                let str = album.strTitle
                let attributedOriginalText =  NSMutableAttributedString(string: str, attributes: arrAttribute1 as [NSAttributedString.Key : Any])
                
                if album.intCount > 0 {
                    let string = " (" + String(album.intCount) + ")"
                    let attr = NSAttributedString(string: string, attributes: arrAttribute2 as [NSAttributedString.Key : Any])
                    attributedOriginalText.append(attr)
                }
                cell.labelTitle.attributedText = attributedOriginalText
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let currentCell = tableView.cellForRow(at: indexPath) as! SearchProductCell
        self.isFromPreviousVC = false
        self.showListAlbum(ishidden: true)
        let album = self.modelAlbum[indexPath.row]
        self.selectedAlbum = album
        if album.asset.hasAssetsImages(){
            self.labelTitle.text = album.strTitle
            self.fetchImagesFromGallery(collection: album.asset)
        }
    }
}

//MARK: - DATA METHODS
extension ALGalleryViewController {
    
    // MARK: - Private methods
    
    private func scrollToTop () {
        if !self.isFromPreviousVC {
            if self.photos.count != 0 {
                let index = IndexPath(row: 0, section: 0)
                self.collectionView.scrollToItem(at: index, at: .top, animated: false)
            }
        }
    }
    
    private func checkAutorizationStatus() {
        PHPhotoLibrary.checkAuthorizationStatus { status in
            if status == .authorized {
                if !self.isFirstLoad {
                    self.fetchAlbums()
                } else {
                    if self.modelAlbum.count > 0 {
                        self.isFirstLoad = false
                    } else {
                        self.fetchInitial()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if status == .restricted {
                        self.popViewController()
                    } else {
                        //                        PCPermissionController.sharedInstance.nav = self.navigationController
                        //                        PCPermissionController.sharedInstance.askPermission(self.view, forPermission: "gallery")
                    }
                }
            }
        }
    }
    
    private func fetchImagesFromGallery(collection: PHAssetCollection?) {
        self.photos = PHFetchResult<PHAsset>()
        DispatchQueue.main.async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
            if let collection = collection {
                self.photos = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            } else {
                self.photos = PHAsset.fetchAssets(with: fetchOptions)
            }
            self.collectionView.reloadData()
            self.scrollToTop()
        }
    }
    
    private func fetchInitial() {
        print("FETCH INITIAL")
        self.modelAlbum.removeAll()
        let fetchOptions = PHFetchOptions()
        
        var results = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: fetchOptions)
        results.enumerateObjects({ (collection, _, _) in
            if (collection.hasAssetsImages()) {
                let album: ModelAlbums = ModelAlbums()
                album.asset = collection
                self.modelAlbum.append(album)
            }
        })
        
        results = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        results.enumerateObjects({ (collection, _, _) in
            if (collection.hasAssetsImages()) {
                var existed: Bool = false
                for album in self.modelAlbum {
                    if album.strTitle == collection.localizedTitle {
                        existed = true
                    }
                }
                
                if !existed {
                    let album: ModelAlbums = ModelAlbums()
                    album.asset = collection
                    self.modelAlbum.append(album)
                }
            }
        })
        
        results =  PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        results.enumerateObjects({ (collection, _, _) in
            var existed: Bool = false
            print("Model album", self.modelAlbum)
            for album in self.modelAlbum {
                if album.strTitle == collection.localizedTitle {
                    existed = true
                }
            }
            
            if !existed {
                if (collection.hasAssetsImages()) {
                    let album: ModelAlbums = ModelAlbums()
                    album.asset = collection
                    self.modelAlbum.append(album)
                }
            }
        })
        
        DispatchQueue.main.async {
            if let album = self.selectedAlbum {
                self.fetchImagesFromGallery(collection: album.asset)
            } else {
                if let album = self.modelAlbum.first {
                    self.selectedAlbum = album
                    self.fetchImagesFromGallery(collection: album.asset)
                }
            }
            print("MODEL", self.modelAlbum.count)
            self.setUIState()
            self.tableview.reloadData()
            var height = CGFloat(85 * self.modelAlbum.count)
            let heightLimit =  self.viewContainer.bounds.size.height - self.viewContainerButton.bounds.size.height
            if height > heightLimit {
                height = heightLimit
            }
            self.consViewOverlay.constant = height
            self.consViewOverLaytableBotToViewContainerButton.constant = -self.consViewOverlay.constant
        }
        
    }
    
    private func fetchAlbums() {
        self.modelAlbum.removeAll()
        
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            
            var results = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: fetchOptions)
            results.enumerateObjects({ (collection, _, _) in
                if (collection.hasAssetsImages()) {
                    let album: ModelAlbums = ModelAlbums()
                    album.asset = collection
                    self.modelAlbum.append(album)
                }
            })
            
            results = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            results.enumerateObjects({ (collection, _, _) in
                var existed: Bool = false
                for album in self.modelAlbum {
                    if album.strTitle == collection.localizedTitle {
                        existed = true
                    }
                }
                
                if !existed {
                    if (collection.hasAssetsImages()) {
                        let album: ModelAlbums = ModelAlbums()
                        album.asset = collection
                        self.modelAlbum.append(album)
                    }
                }
            })
            
            results =  PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            results.enumerateObjects({ (collection, _, _) in
                var existed: Bool = false
                for album in self.modelAlbum {
                    if album.strTitle == collection.localizedTitle {
                        existed = true
                    }
                }
                
                if !existed {
                    if (collection.hasAssetsImages()) {
                        let album: ModelAlbums = ModelAlbums()
                        album.asset = collection
                        self.modelAlbum.append(album)
                    }
                }
            })
            
            DispatchQueue.main.async {
                if let album = self.selectedAlbum {
                    self.fetchImagesFromGallery(collection: album.asset)
                } else {
                    if let album = self.modelAlbum.first {
                        self.selectedAlbum = album
                        self.fetchImagesFromGallery(collection: album.asset)
                    }
                }
                self.setUIState()
            }
        }
    }
    
    private func getCompressedImage(_ image: UIImage, completeHandler: @escaping (UIImage) -> Void) {
        var sampleImg = image
        var floatReduce:Float = 1.0
        let dataImage = NSData(data: sampleImg.jpegData(compressionQuality: 1)!)
        let sizeImageFile: Int = dataImage.count
        let kbData = (Double(sizeImageFile) / 1000.0).rounded()
        print("FILESIZE", kbData)
        if kbData > 20000 {
            floatReduce = 0.5
        }
        guard let newImage: UIImage = sampleImg.downsample(reductionAmount: floatReduce) else {
            return
        }
        if var data = newImage.pngData() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                while data.count > (8 * 1024 * 1024) {
                    var compressionQuality: CGFloat = 0.8
                    
                    if data.count > (20 * 1024 * 1024) {
                        compressionQuality = 0.6
                    }
                    
                    print("Gallery length: \(data.count)")
                    
                    if let jpegData = newImage.jpegData(compressionQuality: compressionQuality) {
                        data = jpegData
                        
                        sampleImg = UIImage(data: jpegData) ?? sampleImg
                    }
                }
                
                completeHandler(sampleImg)
            }
        }
    }
    
    public func setButtonCloseVisibility(isVisible: Bool) {
        buttonClose.isHidden = !isVisible
    }
}

extension ALGalleryViewController {
    private func detectFace(by image: UIImage) -> Bool {
        
        
        return true
    }
    
    private func ciFaceDetector(image: UIImage, completionHandler: (Bool) -> Void) {
        var isFaces = false
        self.isDetectingFace = true
        guard let imageci = CIImage(image: image) else {
            completionHandler(isFaces)
            return
        }
        
        let highAccuracy = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: highAccuracy)
        guard let faces = faceDetector?.features(in: imageci, options: [CIDetectorSmile:true, CIDetectorEyeBlink:true]) else {
            //print("ERROR")
            completionHandler(isFaces)
            return
        }
        
        for _ in faces as! [CIFaceFeature]{
            //if face.rightEyeClosed && face.leftEyeClosed{
            //isFaces = false
            //} else {
            isFaces = true
            //}
        }
        
        completionHandler(isFaces)
    }
    
}

extension CALayer {
    func applySketchShadow(color: UIColor = .lightGray, alpha: Float = 0.1, x: CGFloat = 0, y: CGFloat = -10, blur: CGFloat = 6, spread: CGFloat = 4) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 4.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
            shouldRasterize = true
            rasterizationScale = UIScreen.main.scale
        }
    }
    
    
    func applyRoundedShadow (color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 4) {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath
            
        }
    }
}


class AlbumModel {
    let name:String
    let count:Int
    let collection:PHAssetCollection
    init(name:String, count:Int, collection:PHAssetCollection) {
        self.name = name
        self.count = count
        self.collection = collection
    }
}

//extension PCGalleryViewController: PCCameraVCDelegate {
//    func cameraDidFinishTakeImage(image: UIImage) {
//        DispatchQueue.main.async {
//            self.navigationController?.popViewController(animated: true)
//            self.delegate?.galleryDidFinishSelectImage(image: image)
//        }
//    }
//}
