//
//  SDEffectsPageFundationEditorController.swift
//  cyiOSAISample
//
//  Created by Lucy on 05/12/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

class SDEffectsPageFundationEditorController: ALBaseFundationController {
    
    private var filterParameters: Dictionary<String, Any>?
    
    private var filterCategory: EffectsCategory = .none
    
    private var filterModels: [SDEffectsModel] = []
    private var lookupFilter: GPUImageFilterGroup = GPUImageFilterGroup()
    private var filters = NSMutableArray()
    private var currentIntensity: CGFloat = 1.0
    private var modelCurrentEffectsItem: SDEffectsItem = SDEffectsItem()
    private var selectedLookFilter: Bool = false
    private var originalImage: UIImage = UIImage()
    
    private lazy var imgOriginal: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.isHidden = true
        
        return imageView
    }()
    
    lazy var filterItemView: SDEffectsItemView = {
        let filterItemView = SDEffectsItemView(frame: CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: fundationHeight), delegate: self)
        
        filterItemView.effectsSlider.isHidden = true
        filterItemView.cancelBtn.isHidden = true
        //filterItemView.effectsItemEntrancePage = .editor
        filterItemView.backgroundColor = .clear
        
        return filterItemView
    }()
    
    lazy var adjustEditOperationPannel: ALEditOperationsPanel = {
        let adjustEditOperationPannel = ALEditOperationsPanel()
        adjustEditOperationPannel.isIntensitySliderHidden = true
        adjustEditOperationPannel.isShowOriginalButtonHidden = true
        adjustEditOperationPannel.intensitySliderValue = 1.0
        adjustEditOperationPannel.delegate = self
        
        return adjustEditOperationPannel
    }()
    
    override func functionDidLoad() {
        initializerData()
        configureHeriarchy()
    }
    
    override func functionWillAppear(animation: Bool) {
        super.functionWillAppear(animation: animation)
        
        imageEditorContrainer.isScaleEnable = true
        imageEditorContrainer.titleHidden = false
        imageEditorContrainer.bottomPanelHidden = false
        adjustEditOperationPannel.isHidden = false
        
        originalImage = self.imageEditorContrainer.srcImage
        
        self.setOriginalImageView()
        
//        paddingBottomPannelHeight = 12.cgFloat
        
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: true)), duration: editorAnimationTime, animated: animation)
        
        UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseIn, animations: {
            self.filterItemView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height - self.filterItemView.frame.height.adaptTabberBottom() - paddingBottomPannelHeight - bottomPannelHeight, width: SDConstants.UI.Screen_Width, height: self.filterItemView.frame.height)
        }) { (bool) in
            self.imageEditorContrainer.renderView.addSubview(self.imgOriginal)
            
            self.imgOriginal.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            self.adjustEditOperationPannel.snp.makeConstraints { (make) in
                make.trailing.leading.equalToSuperview()
                make.top.equalTo(self.filterItemView.snp.top)
                make.height.equalTo(adjustRangePanelH)
            }
        }
        
        setupFiltersChain()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.filterItemView.unfloderFilterCollectionWithAnimation()
        }
    }
    
    override func functionWillRemove() {
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: false)), duration: editorAnimationTime, animated: true)
        
        UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseIn, animations: {
            self.filterItemView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: self.filterItemView.frame.height)
            
        }) { (bool) in
            self.adjustEditOperationPannel.isHidden = true
            
//            paddingBottomPannelHeight = 20.cgFloat
            
            self.filterItemView.resetStateEffectsItemView()
            self.imgOriginal.removeFromSuperview()
        }
    }
    
    override func didCancelClick() {
        super.didCancelClick()
        
        imageEditorContrainer.returnPreFundation()
        
        self.adjustEditOperationPannel.isIntensitySliderHidden = true
        self.adjustEditOperationPannel.isShowOriginalButtonHidden = true
        
        self.selectedLookFilter = false
    }
    
    override func didConfirmClick() {
        if self.selectedLookFilter {
            let lookuplookupFilter = self.lookupFilter.imageFromCurrentFramebuffer()
            if let `lookuplookupFilter` = lookuplookupFilter {
                self.imageEditorContrainer.srcImage = lookuplookupFilter
            }
        }
        
        self.filterItemView.resetStateEffectsItemView()
        imageEditorContrainer.returnPreFundation()
        
        self.adjustEditOperationPannel.isIntensitySliderHidden = true
        self.adjustEditOperationPannel.isShowOriginalButtonHidden = true
        
        imageEditorContrainer.showOriginal()
        
        self.selectedLookFilter = false
    }
    
    override func didImageContentFrameChanged(_ newFrame: CGRect, newScale: CGFloat) {
    }
    
    override func onSuccessPurchaseVIP() {
        self.filterItemView.reloadCollectionView()
    }
    
    override func onDismissVIP() {
        self.imageEditorContrainer.showOriginal()
        self.adjustEditOperationPannel.isIntensitySliderHidden = true
        self.adjustEditOperationPannel.isShowOriginalButtonHidden = true
        self.filterItemView.resetSelection()
        
        self.selectedLookFilter = false
    }
}

extension SDEffectsPageFundationEditorController {
    private func initializerData() {
        filterModels = SDEffectsModel.initializerBuiltInFilters()!
        filterParameters = self.parameters
        
       
    }
    
    private func configureHeriarchy() {
        imageEditorContrainer.safeAreaContainer.addSubview(self.filterItemView)
        imageEditorContrainer.safeAreaContainer.addSubview(self.adjustEditOperationPannel)
        
    }
    
    private func setupFiltersChain() {
        self.lookupFilter.addTarget(self.imageEditorContrainer.renderView)
    }
}

extension SDEffectsPageFundationEditorController: ALEditOperationsPanelDelegate {
    func didIntensityChanged(_ sender: UISlider) {
        self.currentIntensity = CGFloat(sender.value)
        self.adjustImage(value: self.currentIntensity)
        self.imageEditorContrainer.srcImageInput.processImage()
    }
    
    func didIntensityChangeEnd(_ sender: UISlider) {
    }
    
    func didShowOriginalBegan() {
        self.imgOriginal.isHidden = false
    }
    
    func didShowOriginalEnd() {
        self.imgOriginal.isHidden = true
    }
}

extension SDEffectsPageFundationEditorController: SDEffectsItemViewDelegate, SDEffectsItemViewDataSource {
    func doCancelEffects() {
        
    }
    
    func doSelectedEffects(effectsItem: SDEffectsItem) {
        
    }
    
    func doSliderChangedEffects(_ sender: UISlider) {
        
    }
    
    func clickCancelFundationInEffectsItemView() {
    }
    
    func clickSliderChangeEffectsWithSlider(_ sender: UISlider) {
    }
    
    func filterEffectsModelsInFilterItemView() -> [SDEffectsModel] {
        return filterModels
    }
    
    func onHoldCompare() {
        
    }
    
    func selectedEffectsFilterItemInFilterItemView(filterItem: SDEffectsItem) {
        
        self.selectedLookFilter = true
        
        //SDAnalyticsManager.effect(filterItem.key)
        
        self.modelCurrentEffectsItem = filterItem
        self.setSliderValue()
        self.imageEditorContrainer.srcImageInput.removeAllTargets()
        self.lookupFilter.useNextFrameForImageCapture()
        
        self.getFilterClass(strClass: filterItem.Lookup)
        self.lookupFilter.addTarget(self.imageEditorContrainer.renderView)
        
        self.imageEditorContrainer.srcImageInput.processImage()
        self.lookupFilter.useNextFrameForImageCapture()
        
        self.imageEditorContrainer.removeVipPage()
        
        self.adjustEditOperationPannel.isIntensitySliderHidden = false
        self.adjustEditOperationPannel.isShowOriginalButtonHidden = false
        
        /*
        if filterItem.isvip && !Utilities.isPurchased() {
            self.imageEditorContrainer.didEntranceVipPage()
            
            self.adjustEditOperationPannel.isIntensitySliderHidden = true
            self.adjustEditOperationPannel.isShowOriginalButtonHidden = true
        }*/
    }
    
    func filterEFfectsModelsInFilterItemView() -> [SDEffectsModel] {
        return filterModels
    }
    
    func filterDefaultModuleNameInFilterEffectsItemView() -> EffectsCategory {
        return filterCategory
    }
    
    func getFilterClass(strClass: String) {
        var filter = GPUImageFilter.init()
        var filterTerminal = GPUImageFilter.init()
        self.lookupFilter.removeAllTargets()
        self.lookupFilter = GPUImageFilterGroup()
        self.imageEditorContrainer.srcImageInput.addTarget(self.lookupFilter)
        
        switch strClass {
        case "GPUImageSketchFilter":
            filter = GPUImageSketchFilter.init()
            break
        case "GPUImageThresholdSketchFilter":
            filter = GPUImageThresholdSketchFilter.init()
            break
        case "GPUImagePixellateFilter":
            filter = GPUImagePixellateFilter.init()
            break
        case "GPUImagePolarPixellateFilter":
            filter = GPUImagePolarPixellateFilter.init()
            break
        case "GPUImageToonFilter":
            filter = GPUImageToonFilter.init()
            break
        case "GPUImageSmoothToonFilter":
            self.lookupFilter = GPUImageSmoothToonFilter.init()
            break
        case "GPUImageCrosshatchFilter":
            filter = GPUImageCrosshatchFilter.init()
            break
        case "GPUImageColorPackingFilter":
            filter = GPUImageColorPackingFilter.init()
            break
        case "GPUImageVignetteFilter":
            filter = GPUImageVignetteFilter.init()
            break
        case "GPUImageSwirlFilter":
            filter = GPUImageSwirlFilter.init()
            break
        case "GPUImageBulgeDistortionFilter":
            filter = GPUImageBulgeDistortionFilter.init()
            break
        case "GPUImagePinchDistortionFilter":
            filter = GPUImagePinchDistortionFilter.init()
            break
        case "GPUImageStretchDistortionFilter":
            filter = GPUImageStretchDistortionFilter.init()
            break
        case "GPUImageGlassSphereFilter":
            filter = GPUImageGlassSphereFilter.init()
            break
        case "GPUImageSphereRefractionFilter":
            filter = GPUImageSphereRefractionFilter.init()
            break
        case "GPUImagePosterizeFilter":
            filter = GPUImagePosterizeFilter.init()
            break
        case "GPUImageCGAColorspaceFilter":
            filter = GPUImageCGAColorspaceFilter.init()
            break
        case "GPUImageEmbossFilter":
            filter = GPUImageEmbossFilter.init()
            break
        case "GPUImagePolkaDotFilter":
            filter = GPUImagePolkaDotFilter.init()
            break
        case "GPUImageHalftoneFilter":
            filter = GPUImageHalftoneFilter.init()
            break
            
        default:
            filter = GPUImageFilter.init()
        }
        
        if strClass != "GPUImageSmoothToonFilter" {
            self.lookupFilter.addFilter(filter)
            
            if self.lookupFilter.filterCount() == 1 {
                self.lookupFilter.initialFilters = [filter]
                self.lookupFilter.terminalFilter = filter
            }
            
            if strClass == "GPUImageColorPackingFilter"  ||
                strClass == "GPUImageCGAColorspaceFilter" {
                filterTerminal = GPUImageContrastFilter.init()
                self.lookupFilter.addFilter(filterTerminal)
                
                if lookupFilter.filterCount() > 1 {
                    let filterLast = self.lookupFilter.terminalFilter
                    let initialFilter = self.lookupFilter.initialFilters
                    
                    filterLast?.addTarget(filterTerminal)
                    self.lookupFilter.initialFilters = [initialFilter![0]]
                    self.lookupFilter.terminalFilter = filterTerminal
                    
                }
            }
            
        } else {
            self.lookupFilter = GPUImageSmoothToonFilter.init()
            self.imageEditorContrainer.srcImageInput.addTarget(self.lookupFilter)
        }
    }
    
    func setSliderValue() {
        self.adjustEditOperationPannel.intensitySliderValue = 1.0
        self.adjustEditOperationPannel.intensitySliderValueMax = 1.0
        self.adjustEditOperationPannel.intensitySliderValueMin = 0.0
        
        if self.modelCurrentEffectsItem.Lookup == "GPUImageVignetteFilter" {
            self.adjustEditOperationPannel.intensitySliderValue = 0.3
        } else if self.modelCurrentEffectsItem.Lookup == "GPUImageBulgeDistortionFilter" ||
            self.modelCurrentEffectsItem.Lookup == "GPUImageSphereRefractionFilter" ||
            self.modelCurrentEffectsItem.Lookup == "GPUImageGlassSphereFilter" {
            self.adjustEditOperationPannel.intensitySliderValue = 0.25
        } else if self.modelCurrentEffectsItem.Lookup == "GPUImageHalftoneFilter" {
            self.adjustEditOperationPannel.intensitySliderValue = 0
        }
        
    }
    
    func adjustImage(value: CGFloat) {
        var values = value
        if value < 0.2  {
            values = 0.2
        }
        switch self.modelCurrentEffectsItem.Lookup {
        case "GPUImageSketchFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageSketchFilter {
                filter.edgeStrength = values
            }
            break
        case "GPUImageThresholdSketchFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageThresholdSketchFilter {
                filter.edgeStrength = values
            }
            break
        case "GPUImagePixellateFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImagePixellateFilter {
                filter.fractionalWidthOfAPixel = values * 0.05
            }
            break
        case "GPUImagePolarPixellateFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImagePolarPixellateFilter {
                filter.pixelSize = CGSize(width: values * 0.05, height: values * 0.05)
            }
            break
        case "GPUImageToonFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageToonFilter {
                filter.quantizationLevels = values * 10.0
                filter.threshold = values * 0.2
            }
            break
        case "GPUImageSmoothToonFilter":
            if let filter = self.lookupFilter.filter(at: 0) as? GPUImageGaussianBlurFilter {
                filter.blurRadiusInPixels = values * 2.0
            }
            break
        case "GPUImageCrosshatchFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageCrosshatchFilter {
                filter.crossHatchSpacing = values * 0.03
                filter.lineWidth = values * 0.003
            }
            break
        case "GPUImageColorPackingFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageContrastFilter {
                filter.contrast = values
                
            }
            break
        case "GPUImageVignetteFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageVignetteFilter {
                if values > 0.50 {
                    values = 0.50
                } else if values < 0.2 {
                    values  = value
                }
                filter.vignetteStart = values
            }
            break
        case "GPUImageSwirlFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageSwirlFilter {
                filter.angle = values
            }
            break
        case "GPUImageBulgeDistortionFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageBulgeDistortionFilter {
                filter.radius = values
            }
            break
        case "GPUImagePinchDistortionFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImagePinchDistortionFilter {
                filter.radius = values
            }
            break
        case "GPUImageStretchDistortionFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageStretchDistortionFilter {
                filter.center = CGPoint(x: values * 0.5, y: values * 0.5)
            }
            break
        case "GPUImageGlassSphereFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageGlassSphereFilter {
                filter.radius = values
            }
            break
        case "GPUImageSphereRefractionFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageSphereRefractionFilter {
                filter.radius = values
            }
            break
        case "GPUImagePosterizeFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImagePosterizeFilter {
                if values < 0.1 {
                    values = 0.1
                }
                filter.colorLevels = UInt(values * 10)
            }
            break
        case "GPUImageCGAColorspaceFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageContrastFilter {
                filter.contrast = values
            }
            break
        case "GPUImageEmbossFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageEmbossFilter {
                filter.intensity = values
            }
            break
        case "GPUImagePolkaDotFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImagePolkaDotFilter {
                
                filter.fractionalWidthOfAPixel = values * 0.05
            }
            break
        case "GPUImageHalftoneFilter":
            if let filter = self.lookupFilter.terminalFilter as? GPUImageHalftoneFilter {
                filter.fractionalWidthOfAPixel = values * 0.05
            }
            break
            
        default:
            break
        }
        
        self.imageEditorContrainer.srcImageInput.processImage()
    }
    
    private func setOriginalImageView() {
        imgOriginal.image = self.originalImage
    }
}
