//
//  SDArtFilterPageFundationEditorController.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/13.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyUserDefaults

class ALArtFilterPageFundationEditorController: ALBaseFundationController {
    private var filterParameters: Dictionary<String, Any>?
    var modelArtSelected: ALArtModel?
    private var artModels: [ALArtModel] = []
    private var oilPaintMaskImage: GPUImagePicture?
    private var alphaBlendFilter: GPUImageAlphaBlendFilter?
    private var originalImage: UIImage = UIImage()
    private var filters = NSMutableArray()
    private var isSubscription: Bool = false
    
    lazy var vwFilter: ALArtFilterView = {
        let vwFilter = ALArtFilterView.init(frame: CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: fundationHeight), delegate: self)
        vwFilter.backgroundColor = .clear
        
        return vwFilter
    }()
    
    private lazy var imgOriginal: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.isHidden = true
        
        return imageView
    }()
    
    override func functionDidLoad() {
        super.functionDidLoad()
        
        initializerData()
        configureHeriarchy()
        
    }
    
    override func functionWillAppear(animation: Bool) {
        super.functionWillAppear(animation: animation)
        
        originalImage = self.imageEditorContrainer.srcImage
        
        self.setOriginalImageView()
        
        imageEditorContrainer.isScaleEnable = true
        imageEditorContrainer.titleHidden = false
        imageEditorContrainer.bottomPanelHidden = false
        
//        paddingBottomPannelHeight = 12.cgFloat
        
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: true)), duration: editorAnimationTime, animated: animation)
        
        UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseIn, animations: {
            self.vwFilter.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height - self.vwFilter.frame.height.adaptTabberBottom() - paddingBottomPannelHeight - bottomPannelHeight, width: SDConstants.UI.Screen_Width, height: self.vwFilter.frame.height)
        }) { (bool) in
            self.imageEditorContrainer.renderView.addSubview(self.imgOriginal)
            
            self.imgOriginal.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.vwFilter.unfolderFilterCollectionWithAnimation()
            if let model = self.modelArtSelected {
                self.vwFilter.selectedArt = model
                self.vwFilter.isApply = true
                self.vwFilter.reloadCollectionView()
                var indexPath = IndexPath(row: 0, section: 0)
                for (index,modelart) in self.artModels.enumerated() {
                    if modelart.key == model.key {
                        indexPath.row = index
                    }
                }
                self.vwFilter.artCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.doSelect(art: model)
                
            }
        }
    }
    
    override func functionWillRemove() {
        super.functionWillRemove()
        
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: false)), duration: editorAnimationTime, animated: true)
        
        UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseIn, animations: {
            self.vwFilter.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: self.vwFilter.frame.height)
        }) { (bool) in
//            paddingBottomPannelHeight = 20.cgFloat
            
            self.imgOriginal.removeFromSuperview()
        }
    }
    
    override func didCancelClick() {
        super.didCancelClick()
        
        imageEditorContrainer.returnPreFundation()
        
        imageEditorContrainer.srcImage = originalImage
        imageEditorContrainer.setFundationTitle(text: "")
        self.vwFilter.reset()
    }
    
    override func didConfirmClick() {
        super.didConfirmClick()
        
        imageEditorContrainer.setFundationTitle(text: "")
        if self.vwFilter.selectedArt == nil {
           // imageEditorContrainer.returnPreFundation()
            
            self.vwFilter.reset()
            
            return
        }
        
        (self.filters.lastObject as! SDFilterPackage).filter.useNextFrameForImageCapture()
        
        self.oilPaintMaskImage?.processImage(completionHandler: {
            self.imageEditorContrainer.srcImageInput.processImage {
                guard let filterImage = (self.filters.lastObject as! SDFilterPackage).filter.imageFromCurrentFramebuffer() else { return }
                self.clearGPUImageProcess()
                
                self.imageEditorContrainer.srcImage = filterImage
                
                DispatchQueue.main.async {
                    //self.imageEditorContrainer.returnPreFundation()
                    
                    self.imageEditorContrainer.showEffected()
                    self.imageEditorContrainer.finish(byChanel: true)
                    self.vwFilter.reset()
                }
            }
        })
    }
    
    override func onSuccessPurchaseVIP() {
        vwFilter.reloadCollectionView()
        if isSubscription {
            isSubscription = false
        }
    }
    
    override func onDismissVIP() {
        imageEditorContrainer.setFundationTitle(text: "")
        isSubscription = false
        vwFilter.reset()
        self.imageEditorContrainer.showOriginal()
    }
    
    override func onRetryConnection() {
        
    }
    
    override func didImageContentFrameChanged(_ newFrame: CGRect, newScale: CGFloat) {
    }
}

extension ALArtFilterPageFundationEditorController {
    private func initializerData() {
        guard let artModels = ALArtModel.initialize() else { return }
        self.artModels = artModels
        filterParameters = self.parameters
        
        if let parameters = filterParameters {
           
            if self.isSubscription {
                imageEditorContrainer.didEntranceVipPage()
//                self.isSubscription = false
            }
        }
    }
    
    private func configureHeriarchy() {
        self.imageEditorContrainer.safeAreaContainer.addSubview(self.vwFilter)
    }
}

extension ALArtFilterPageFundationEditorController: SDArtFilterViewDelegate, SDArtFilterViewDataSource {
    
    func onHoldCompare(art: ALArtModel?) {
        self.imgOriginal.isHidden = false
    }
    
    func onUnholdCompare(art: ALArtModel?) {
        self.imgOriginal.isHidden = true
    }
    
    func doDiscard() {
        self.imageEditorContrainer.showOriginal()
    }
    
    func doSelect(art: ALArtModel?) {
        imageEditorContrainer.setFundationTitle(text: (art?.key.localized(name: "Filters"))!)
        self.setArt(art!, intensity: 1.0, loading: true)
    }
    
    func doPremium(art: ALArtModel?) {
    
        imageEditorContrainer.setFundationTitle(text: (art?.key.localized(name: "Filters"))!)
        
        self.imageEditorContrainer.didEntranceVipPage()
    }
    
    func onIntensityValueChanged(art: ALArtModel?, value: CGFloat) {
        self.alphaBlendFilter?.mix = value
        
        self.process()
    }
    
    func artModelsView() -> [ALArtModel] {
        return artModels
    }
}

extension ALArtFilterPageFundationEditorController {
    private func setArt(_ art: ALArtModel, intensity: CGFloat, loading: Bool) {
        //SDAnalyticsManager.arts(art.key)
        
        self.imageEditorContrainer.removeVipPage()
        if loading {
            self.imageEditorContrainer.openLoadingPage()
        }
        self.imageEditorContrainer.srcImage = originalImage
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            DispatchQueue.global().async {
                ALArtModel.getLookupArt(art.lookup, image: self.imageEditorContrainer.srcImage.resetPixelArtisticFilterOriginalImage()) { (image) in
                    if let img = image {
                        let concurentQueue = DispatchQueue(label: "Art")
                        concurentQueue.async {
                            autoreleasepool {
                                self.oilPaintMaskImage = GPUImagePicture.init(image: self.imageEditorContrainer.srcImage)
                                self.alphaBlendFilter = GPUImageAlphaBlendFilter.init()
                                self.alphaBlendFilter?.useNextFrameForImageCapture()
                                self.oilPaintMaskImage?.addTarget(self.alphaBlendFilter)
                                self.alphaBlendFilter?.mix = 1.0
                                
                                let package = SDFilterPackage.init(filter: self.alphaBlendFilter, filterType: 0)
                                self.createSourcePictureWithImage(img)
                                self.processImage(package!)
                            }
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                            self.imageEditorContrainer.closeLoadingPage()
                        })
                    }
                    
                    DispatchQueue.main.async {
//                        if art.isvip && !Utilities.isPurchased() {
//                            Defaults[.sourcePage] = "arts"
//                            Defaults[.typeOfPage] = art.key
//                            self.imageEditorContrainer.didEntranceVipPage()
//                        }
                    }
                }
            }
        }
    }
    
    private func createSourcePictureWithImage(_ img: UIImage) {
        self.imageEditorContrainer.srcImageInput.removeAllTargets()
        self.imageEditorContrainer.srcImageInput.removeFramebuffer()
        guard let sourcePicture = GPUImagePicture.init(image: img, smoothlyScaleOutput: true) else { return }
        self.imageEditorContrainer.srcImageInput = sourcePicture
    }
    
    private func clearGPUImageProcess() {
        self.imageEditorContrainer.srcImageInput.removeAllTargets()
        self.clearFilters()
    }
    
    private func clearFilters() {
        self.filters.enumerateObjects { (obj, idx, stop) in
            let filterPackage = obj as! SDFilterPackage
            filterPackage.filter.removeAllTargets()
            filterPackage.filter.removeFramebuffer()
        }
    }
    
    private func processImage(_ filterPackage: SDFilterPackage) {
        if filterPackage.filter == nil {
            self.removeFilter(filterPackage)
            self.integrateFilters()
            
            self.process()
            
            return
        }
        
        var contained = false
        self.filters.enumerateObjects { (obj, index, stop) in
            let _filterPackage = obj as! SDFilterPackage
            if _filterPackage.filterType == filterPackage.filterType {
                _filterPackage.filter = filterPackage.filter
                
                contained = true
                
                stop.pointee = true
            }
        }
        
        if !contained {
            if filterPackage.filterType == 0 {
                self.filters.insert(filterPackage, at: 0)
            } else {
                self.filters.add(filterPackage)
            }
        }
        
        self.integrateFilters()
        self.process()
    }
    
    private func process() {
        self.oilPaintMaskImage?.processImage(completionHandler: {
            self.imageEditorContrainer.srcImageInput.processImage(completionHandler: {
                DispatchQueue.main.async {
                    self.imageEditorContrainer.closeLoadingPage()
                }
            })
        })
    }
    
    private func integrateFilters() {
        self.clearGPUImageProcess()
        
        if self.filters.count == 0 {
            self.imageEditorContrainer.srcImageInput.addTarget(self.imageEditorContrainer.renderView)
            
            return
        }
        
        for i in 0..<self.filters.count {
            let filterPackage = self.filters[i] as! SDFilterPackage
            let filter = filterPackage.filter
            if i == 0 {
                self.imageEditorContrainer.srcImageInput.addTarget(filter)
            }
            if i == self.filters.count - 1 {
                filter?.addTarget(self.imageEditorContrainer.renderView)
            } else {
                let nextFilter = self.filters[i + 1] as! SDFilterPackage
                filter?.addTarget(nextFilter.filter)
            }
        }
    }
    
    private func removeFilter(_ filterPackage: SDFilterPackage?) {
        if filterPackage != nil {
            return
        }
        var tempPackage: SDFilterPackage?
        self.filters.enumerateObjects { (obj, idx, stop) in
            let _filterPackage = obj as! SDFilterPackage
            if _filterPackage.filterType == filterPackage?.filterType {
                tempPackage = _filterPackage
                
                stop.pointee = true
            }
        }
        
        if tempPackage != nil {
            self.filters.remove(tempPackage as Any)
        }
    }
    
    private func setOriginalImageView() {
        imgOriginal.image = self.originalImage
    }
}
