//
//  SDAdjustPageEditorFundationController.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/6.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class ALAdjustPageEditorFundationController: ALBaseFundationController {
    
    private var currentFundation: SDFundation?
    private var adjustEffect: SDAdjustmentEffect!
    
    private var storedSelectedFundation: [Int:[SDFundation:CGFloat]] = [:]
    
    private var storeUndoStack: [UndoOperator] = []
    private var storeRedoStack: [UndoOperator] = []
    private var storeIntensitiesElements: [SDFundation:([IntensityEffectWrapper.IntensityItem], [IntensityEffectWrapper.IntensityItem])] = [:]
    private var storeIntensites: [SDFundation: CGFloat] = [:]
    
    //MARK:
    private var operationStack: [UndoOperator] = []
    private var cacheOperationStack: [UndoOperator] = []
    private var effectIntensityBeforChanged: CGFloat?
    
    private var tempPictureInput: GPUImagePicture?
    private var tempAdjustEffect: SDAdjustmentEffect?
    
    var flag: Bool = false
    
    private var fundationModels: [FundationModel] = []
    
    private var cropRatioView: SDCropRatioView!
    private var isChanged: Bool = false
    private var isMirrored: Bool = false
    
    private var countUndo = 0
    
    override func functionDidLoad() {
        initializerData()
        configureHeriarchy()
    }
    
    override func functionWillAppear(animation: Bool) {
        countUndo = 0
        adjustEffect = SDAdjustmentEffect()
        
        imageEditorContrainer.isScaleEnable = true
        imageEditorContrainer.titleHidden = false
        imageEditorContrainer.bottomPanelHidden = false
        adjustEditOperationPannel.alpha = 1.0
        self.adjustEditOperationPannel.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(didSliderValueUpdate(_:)), name: .UIEffectIntensityNotification, object: nil)
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: true)), duration: editorAnimationTime, animated: animation)
        
        self.adjustEditOperationPannel.snp.remakeConstraints { (make) in
            make.trailing.leading.equalToSuperview()
            make.top.equalTo(self.fundationCollectionView.snp.top)
            make.height.equalTo(adjustRangePanelH)
        }
        
        cropRatioView = SDCropRatioView(frame: CGRect(x: 0, y: 0, width: self.imageEditorContrainer.renderView.frame.size.width, height: self.imageEditorContrainer.renderView.frame.size.height))
        imageEditorContrainer.renderView.addSubview(cropRatioView)
        cropRatioView.setNeedsDisplay()
        
        UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseIn, animations: {
            self.fundationCollectionView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height - self.fundationCollectionView.frame.height.adaptTabberBottom() - paddingBottomPannelHeight - bottomPannelHeight, width: SDConstants.UI.Screen_Width, height: self.fundationCollectionView.frame.height)
        }) { (bool) in
        }
        
        setupChain()
    }
    
    override func functionWillRemove() {
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: false)), duration: editorAnimationTime, animated: true)
        
        self.cropRatioView.isHidden = true
        
        clearCachedStatus()
        DispatchQueue.main.async {
            UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                self.fundationCollectionView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: self.fundationCollectionView.frame.width, height: self.fundationCollectionView.frame.height)
                self.adjustEditOperationPannel.alpha = 0.0
                
            }) { (bool) in
                self.adjustEditOperationPannel.isHidden = false
                self.cropRatioView.removeFromSuperview()
            }
        }
        self.fundationCollectionView.resetAdjustFundationState()
        self.adjustEditOperationPannel.isRedoButtonHidden = true
        self.adjustEditOperationPannel.isUndoButtonHidden = true
        self.storeIntensites.removeAll()
        self.storeIntensitiesElements.removeAll()
        self.operationStack.removeAll()
        self.cacheOperationStack.removeAll()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didCancelClick() {
        super.didCancelClick()
        
        if isMirrored && Int(adjustEffect.defaultIntensity(for: .mirror))%2 != 0{
            let mirrorImage = self.imageEditorContrainer.srcImage.mirrorImageInHorizontal()
            self.imageEditorContrainer.srcImage = mirrorImage
            
            self.imageEditorContrainer.srcImageInput.removeAllTargets()
            self.imageEditorContrainer.srcImageInput = GPUImagePicture(cgImage: self.imageEditorContrainer.srcImage.cgImage)
            setupChain()
            self.imageEditorContrainer.srcImageInput.processImage()
        }
        
        isChanged = false
        isMirrored = false
        
        self.clearCachedStatus()
        self.operationStack.removeAll()
        self.cacheOperationStack.removeAll()
        self.resetSliderValue()
        imageEditorContrainer.returnPreFundation()
        self.fundationCollectionView.resetAdjustFundationState()
    }
    
    func resetSliderValue() {
        guard let currentFundation = currentFundation else { return }
        
        self.adjustEffect.updateIntensity(.exposure, value: adjustEffect.defaultIntensity(for: .exposure))
        
        self.adjustEffect.updateIntensity(.saturation, value: adjustEffect.defaultIntensity(for: .saturation))
        
        self.adjustEffect.updateIntensity(.sharpen, value: adjustEffect.defaultIntensity(for: .sharpen))
        
        self.adjustEffect.updateIntensity(.hightlight, value: adjustEffect.defaultIntensity(for: .hightlight))
        
        self.adjustEffect.updateIntensity(.shadow, value: adjustEffect.defaultIntensity(for: .shadow))
        
        self.adjustEffect.updateIntensity(.warmth, value: adjustEffect.defaultIntensity(for: .warmth))
        
        self.adjustEffect.updateIntensity(.vignette, value: adjustEffect.defaultIntensity(for: .vignette))
        
        self.adjustEffect.updateIntensity(.contrast, value: adjustEffect.defaultIntensity(for: .contrast))
        
        self.adjustEffect.updateIntensity(.mirror, value:adjustEffect.defaultIntensity(for: .mirror))
        
    }
    
    override func didConfirmClick() {
        isMirrored = false
        if !isChanged{
            self.restoreStroredStatus()
            self.imageEditorContrainer.returnPreFundation()
            self.imageEditorContrainer.showEffected()
            
            self.fundationCollectionView.resetAdjustFundationState()
            return
        }
        
        isChanged = false
        
        if !flag {
            flag = true
            recordAllStatus()
            
            tempPictureInput = GPUImagePicture(image: self.imageEditorContrainer.srcImage)
            tempAdjustEffect = SDAdjustmentEffect()
            
            
            let exposure = storeIntensites[.exposure]
            let contrast = storeIntensites[.contrast]
            let saturation = storeIntensites[.saturation]
            let sharpen = storeIntensites[.sharpen]
            let highlight = storeIntensites[.hightlight]
            let shadow = storeIntensites[.shadow]
            let warmth = storeIntensites[.warmth]
            let vignette = storeIntensites[.vignette]
            
            tempAdjustEffect!.updateIntensity(.exposure, value: exposure!)
            tempAdjustEffect!.updateIntensity(.contrast, value: contrast!)
            tempAdjustEffect!.updateIntensity(.saturation, value: saturation!)
            tempAdjustEffect!.updateIntensity(.sharpen, value: sharpen!)
            tempAdjustEffect!.updateIntensity(.hightlight, value: highlight!)
            tempAdjustEffect!.updateIntensity(.shadow, value: shadow!)
            tempAdjustEffect!.updateIntensity(.warmth, value: warmth!)
            tempAdjustEffect!.updateIntensity(.vignette, value: vignette!)
            
            tempPictureInput?.addTarget(tempAdjustEffect!.inputFilter)
            tempAdjustEffect!.inputFilter.addTarget(tempAdjustEffect!.outputFilter)
            tempAdjustEffect!.outputFilter.addTarget(self.imageEditorContrainer.renderView)
            
            tempAdjustEffect!.outputFilter.useNextFrameForImageCapture()
            
            self.imageEditorContrainer.srcImageInput.processImage {
                self.tempPictureInput?.processImage(completionHandler: {
                    let newImage = self.tempAdjustEffect?.outputFilter.imageFromCurrentFramebuffer()
                    self.imageEditorContrainer.srcImage = newImage!
                    
                    DispatchQueue.main.async {
                        self.imageEditorContrainer.returnPreFundation()
                        self.imageEditorContrainer.showOriginal()
                    }
                    
                    self.flag = false
                })
            }
            
        }
    }
    
    
    // MARK: - Lazying
    
    lazy var fundationCollectionView:SDAdjustFundationConllectView = {
        let fundationCollectionView = SDAdjustFundationConllectView(frame: CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: fundationHeight), delegate: self)
        return fundationCollectionView
    }()
    
    lazy var adjustEditOperationPannel: ALEditOperationsPanel = {
        let adjustEditOperationPannel = ALEditOperationsPanel()
        adjustEditOperationPannel.isIntensitySliderHidden = true
        adjustEditOperationPannel.isShowOriginalButtonHidden = true
        adjustEditOperationPannel.intensitySliderValue = 0
        adjustEditOperationPannel.delegate = self
        
        return adjustEditOperationPannel
    }()
    
}

// MARK: - Initialzier & Heriarchy

extension ALAdjustPageEditorFundationController {
    private func initializerData() {
        
        adjustEffect = SDAdjustmentEffect()
        
        fundationModels = [
            FundationModel(.exposure, fundationname: "Brightness", fundationimagename: "editor_brightness", hasChangedValue: false, isselected: false),
            FundationModel(.contrast, fundationname: "Contrast", fundationimagename: "editor_contrast", hasChangedValue: false, isselected: false),
            FundationModel(.saturation, fundationname: "Saturation", fundationimagename: "editor_saturation", hasChangedValue: false, isselected: false),
            FundationModel(.sharpen, fundationname: "Sharpness", fundationimagename: "editor_sharpness", hasChangedValue: false, isselected: false),
            FundationModel(.hightlight, fundationname: "Highlight", fundationimagename: "editor_highlight", hasChangedValue: false, isselected: false),
            FundationModel(.shadow, fundationname: "Shadow", fundationimagename: "editor_shadow", hasChangedValue: false, isselected: false),
            FundationModel(.warmth, fundationname: "Temperature", fundationimagename: "editor_temperature", hasChangedValue: false, isselected: false),
            FundationModel(.vignette, fundationname: "Vignette", fundationimagename: "editor_vignette", hasChangedValue: false, isselected: false),
            FundationModel(.mirror, fundationname: "Mirror", fundationimagename: "editor_mirror", hasChangedValue: false, isselected: false)
            /*FundationModel(.rotate, fundationname: SDMutableLanguages.Editor.RotateInAdjustmentFundation, fundationimagename: "editor_rotate", hasChangedValue: false, isselected: false)*/
            /*FundationModel(.vertical, fundationname: SDMutableLanguages.Editor.VerticalInAdjustmentFundation, fundationimagename: "editor_vertical", hasChangedValue: false, isselected: false),
             FundationModel(.horizontal, fundationname: SDMutableLanguages.Editor.HorizontalInAdjustmentFundation, fundationimagename: "editor_horizontal", hasChangedValue: false, isselected: false)*/]
        
    }
    
    private func configureHeriarchy() {
        imageEditorContrainer.safeAreaContainer.addSubview(self.fundationCollectionView)
        imageEditorContrainer.safeAreaContainer.addSubview(self.adjustEditOperationPannel)
    }
    
}

// MARK: - Private Method

extension ALAdjustPageEditorFundationController {
    private func cropTo(srcimage: UIImage, referenceObjectSize: CGSize, cropRect: CGRect) -> UIImage? {
        
        let ctx = UIGraphicsGetCurrentContext()
        UIGraphicsBeginImageContext(referenceObjectSize)
        ctx?.draw(srcimage.cgImage!, in: CGRect(x: 0, y: 0, width: referenceObjectSize.width, height: referenceObjectSize.height))
        
        let xRatio = cropRect.origin.x / referenceObjectSize.width
        let yRatio = cropRect.origin.y / referenceObjectSize.height
        let positionX = xRatio * srcimage.size.width//cropRect.origin.x//xRatio * srcimage.size.width
        let positionY = yRatio * srcimage.size.height//cropRect.origin.y//yRatio * srcimage.size.height
        let wRatio = cropRect.size.width / referenceObjectSize.width
        let hRatio = cropRect.size.height / referenceObjectSize.height
        let sizeW = wRatio * srcimage.size.width//cropRect.size.width //wRatio * srcimage.size.width
        let sizeH = hRatio * srcimage.size.height//cropRect.size.height//hRatio * srcimage.size.height
        let imageRef = srcimage.cgImage?.cropping(to: CGRect(x: positionX, y: positionY, width: sizeW, height: sizeH))
        
        if imageRef == nil { return nil }
        
        let image = UIImage.init(cgImage: imageRef!)
        
        return image
        
    }
    
    private func setupChain() {
        self.imageEditorContrainer.srcImageInput.removeAllTargets()
        
        self.imageEditorContrainer.srcImageInput.addTarget(self.adjustEffect.inputFilter)
        self.adjustEffect.inputFilter.addTarget(self.adjustEffect.outputFilter)
        self.adjustEffect.outputFilter.addTarget(self.imageEditorContrainer.renderView)
        
        self.adjustEffect.inputFilter.useNextFrameForImageCapture()
        self.adjustEffect.outputFilter.useNextFrameForImageCapture()
    }
    
    private func resetStatus() {
        SDFundation.forEach { (function) in
            adjustEffect.updateIntensity(function, value: adjustEffect.defaultIntensity(for: function))
        }
        
        recordAllStatus()
    }
    
    private func recordAllStatus() {
        clearCachedStatus()
        storeUndoStack.append(contentsOf: operationStack)
        storeRedoStack.append(contentsOf: cacheOperationStack)
        
        SDFundation.forEach { (function) in
            storeIntensites[function] = adjustEffect.intensity(for: function)
        }
        
        SDFundation.forEach { (function) in
            storeIntensitiesElements[function] = (Array(adjustEffect.intensityWrapperFor(function).items), Array(adjustEffect.intensityWrapperFor(function).cacheItems))
        }
    }
    
    private func restoreStroredStatus() {
        clearCachedStatus()
        storeUndoStack.append(contentsOf: operationStack)
        storeRedoStack.append(contentsOf: cacheOperationStack)
        
        operationStack.replaceAllWith(storeUndoStack)
        cacheOperationStack.replaceAllWith(storeRedoStack)
        
        self.adjustEditOperationPannel.isUndoButtonEnable = !operationStack.isEmpty
        self.adjustEditOperationPannel.isRedoButtonEnable = !cacheOperationStack.isEmpty
    
      
        for (function, intensityStored) in storeIntensites {
            adjustEffect.updateIntensity(function, value: intensityStored, requestRender: false)
        }
        
        for (funcation, (undoElements, redoElements)) in storeIntensitiesElements {
            let intensitiesWrapper = adjustEffect.intensityWrapperFor(funcation)
            
            intensitiesWrapper.items.replaceAllWith(undoElements)
            intensitiesWrapper.cacheItems.replaceAllWith(redoElements)
        }
        
    }
    
    private func clearCachedStatus() {
        storeUndoStack.removeAll()
        storeRedoStack.removeAll()
        storeIntensitiesElements.removeAll()
    }
    
    private func appendUndoOperator(_ operation: UndoOperator) {
        operationStack.append(operation)
        cacheOperationStack.forEach { $0.clearRedoStack() }
        cacheOperationStack.removeAll()
        
        DispatchQueue.main.async {
            self.adjustEditOperationPannel.isUndoButtonEnable = true
            self.adjustEditOperationPannel.isRedoButtonEnable = false
        }
        
    }
    
}

// MARK: - SDEditOperationsPanelDelegate

extension ALAdjustPageEditorFundationController: ALEditOperationsPanelDelegate {
    
    func didIntensityChanged(_ sender: UISlider) {
        guard let currentFundation = currentFundation else { return }
        if self.effectIntensityBeforChanged == nil {
            effectIntensityBeforChanged = adjustEffect.intensity(for: currentFundation)
            //TODO
        }
        
        self.adjustEditOperationPannel.isShowSilderValueHidden = true
        self.adjustEditOperationPannel.isShowOriginalButtonHidden = false
        self.adjustEditOperationPannel.isUndoButtonHidden = false
        
        self.adjustEditOperationPannel.intensitySliderValueString = "\(adjustEffect.userIntensity(for: currentFundation, slider: CGFloat(sender.value)))"
        
        adjustEffect.updateIntensity(currentFundation, value: CGFloat(sender.value))
        
        self.imageEditorContrainer.srcImageInput.processImage()
    }
    
    func didIntensityChangeEnd(_ sender: UISlider) {
        guard let currentFundation = currentFundation else { return }
        
        self.adjustEditOperationPannel.isShowSilderValueHidden = false
        
        if let valueBeforeChanged = self.effectIntensityBeforChanged {
            effectIntensityBeforChanged = nil
            adjustEffect.recordIntensity(for: currentFundation, fromValue: valueBeforeChanged, toValue: CGFloat(sender.value))
            appendUndoOperator(adjustEffect.intensityWrapperFor(currentFundation))
        }
        
        let currentIntensity = adjustEffect.intensity(for: currentFundation)
        let defaultIntensity = adjustEffect.defaultIntensity(for: currentFundation)
        let hasChanged = self.covertDeltaToInt(float: currentIntensity, another: defaultIntensity) != 0
        self.fundationCollectionView.updateAdjustFundationState(current: currentFundation, hidden: hasChanged)
        
        storeIntensites[currentFundation] = CGFloat(sender.value)
        storedSelectedFundation[storedSelectedFundation.count] = [currentFundation:CGFloat(sender.value)]
        isChanged = true
    }
    
    @objc func didSliderValueUpdate(_ notification: NSNotification) {
        let fundationId = notification.userInfo![NSNotification.Key.ImageEditor.FundationId] as! Int
        let intensity = notification.userInfo![NSNotification.Key.ImageEditor.Intensity] as? CGFloat
        
        if SDFundation(rawValue: fundationId) == SDFundation.mirror {
            self.adjustEffect.updateIntensity(.mirror, value: CGFloat(intensity!))
            self.dealImageWithMirrorFundation()
            
            return
        }
        
        if fundationId == currentFundation?.rawValue ?? -1 {
            self.adjustEditOperationPannel.intensitySliderValue = Float(intensity!)
            
        }
        
        self.adjustEffect.updateIntensity(SDFundation(rawValue: fundationId)!, value: intensity!)
        print("adjust effect fundationId:\(fundationId) intensity: \(intensity!)")
        
        let currentIntensity = adjustEffect.intensity(for: SDFundation(rawValue: fundationId)!)
        let defaultIntensity = adjustEffect.defaultIntensity(for: SDFundation(rawValue: fundationId)!)
        
        let hasChanged = covertDeltaToInt(float: currentIntensity, another: defaultIntensity) != 0
        self.fundationCollectionView.updateAdjustFundationState(current: SDFundation(rawValue: fundationId)!, hidden: hasChanged)
        
        self.imageEditorContrainer.srcImageInput.processImage()
    }
    
    func didUndoClick() {
        if !operationStack.isEmpty {
            let undoOperator = operationStack.popLast()!
            undoOperator.undo()
            cacheOperationStack.append(undoOperator)
            countUndo += 1
            self.adjustEditOperationPannel.isUndoButtonEnable = !operationStack.isEmpty
            self.adjustEditOperationPannel.isRedoButtonEnable = true
            self.adjustEditOperationPannel.isRedoButtonHidden = false
        }
        
    }
    
    func didRedoClick() {
        if !cacheOperationStack.isEmpty {
            let redoOperator = cacheOperationStack.popLast()!
            redoOperator.redo()
            operationStack.append(redoOperator)
            countUndo -= 1
            self.adjustEditOperationPannel.isUndoButtonEnable = true
            self.adjustEditOperationPannel.isUndoButtonHidden = false
            self.adjustEditOperationPannel.isRedoButtonEnable = !cacheOperationStack.isEmpty
        }
        
        self.imageEditorContrainer.srcImageInput.processImage()
    }
    
    func didShowOriginalBegan() {

        if Int(adjustEffect.defaultIntensity(for: .mirror))%2 != 0 {
            let mirrorImage = self.imageEditorContrainer.srcImage.mirrorImageInHorizontal()
            self.imageEditorContrainer.srcImage = mirrorImage
            
            self.imageEditorContrainer.srcImageInput.removeAllTargets()
            self.imageEditorContrainer.srcImageInput = GPUImagePicture(cgImage: self.imageEditorContrainer.srcImage.cgImage)
            setupChain()
        }
        
        
              
        adjustEffect.updateIntensity(.exposure, value: adjustEffect.defaultIntensity(for: .exposure))
        adjustEffect.updateIntensity(.saturation, value: adjustEffect.defaultIntensity(for: .saturation))
        adjustEffect.updateIntensity(.sharpen, value: adjustEffect.defaultIntensity(for: .sharpen))
        adjustEffect.updateIntensity(.hightlight, value: adjustEffect.defaultIntensity(for: .hightlight))
        adjustEffect.updateIntensity(.shadow, value: adjustEffect.defaultIntensity(for: .shadow))
        adjustEffect.updateIntensity(.warmth, value: adjustEffect.defaultIntensity(for: .warmth))
        adjustEffect.updateIntensity(.vignette, value: adjustEffect.defaultIntensity(for: .vignette))
        adjustEffect.updateIntensity(.contrast, value: adjustEffect.defaultIntensity(for: .contrast))
        
        self.imageEditorContrainer.srcImageInput.processImage()
    }
    
    func didShowOriginalEnd() {
        if Int(adjustEffect.defaultIntensity(for: .mirror))%2 != 0 {
            self.dealImageWithMirrorFundation()
        }else {
            if(!operationStack.isEmpty)
            {
                for(index, fundations) in storedSelectedFundation where index >= storedSelectedFundation.count - countUndo{
                    for(fundation, _) in fundations{
                        storeIntensites[fundation] = adjustEffect.defaultIntensity(for: fundation)
                    }
                }
                restoreStroredStatus()
                self.imageEditorContrainer.srcImageInput.processImage()
                
                for(index, fundations) in storedSelectedFundation where index >= storedSelectedFundation.count - countUndo{
                    for(fundation, val) in fundations{
                        storeIntensites[fundation] = val
                    }
                }
            }
        }
    }
    
    private func covertDeltaToInt(float one: CGFloat, another: CGFloat) -> Int {
        return Int((one - another) * 100)
    }
    
}


// MARK: - SDAdjustFundationViewDelegate & SDAdjustFundationViewDatesource

extension ALAdjustPageEditorFundationController: SDAdjustFundationViewDelegate, SDAdjustFundationViewDataSource {

    func numberAdjustFundationModels() -> [FundationModel] {
        return fundationModels
    }
    
    func didSelectedModelInAdjustFundationView(selectedFundation model: FundationModel) {
        self.adjustEditOperationPannel.isHidden = false
        currentFundation = model.fundation
        if let `currentFundation` = currentFundation {
            if currentFundation == .mirror {
                isMirrored = true
                self.dealImageWithMirrorFundation()
                let valueBeforeChanged = self.adjustEffect.defaultIntensity(for: .mirror)
                adjustEffect.recordIntensity(for: currentFundation, fromValue: valueBeforeChanged, toValue: valueBeforeChanged + 1)
                adjustEffect.updateIntensity(currentFundation, value: 1)
                appendUndoOperator(adjustEffect.intensityWrapperFor(currentFundation))
                self.adjustEditOperationPannel.isUndoButtonHidden = false
                self.adjustEditOperationPannel.isIntensitySliderHidden = true
                self.adjustEditOperationPannel.isShowOriginalButtonHidden = false
                
            }else {
                self.adjustEditOperationPannel.isIntensitySliderHidden = false
                self.adjustEditOperationPannel.intensitySliderValue = 0
                adjustEditOperationPannel.intensitySliderValue = Float(adjustEffect.rangeHelperFor(currentFundation).intensity)
                if currentFundation == .vertical || currentFundation == .horizontal {
                    self.cropRatioView.isHidden = false
                }
                else{
                    self.cropRatioView.isHidden = true
                }
            }
        }
        
    }
    
    //MARK: mirror image
    private func dealImageWithMirrorFundation() {
        DispatchQueue.main.async {
            let mirrorImage = self.imageEditorContrainer.srcImage.mirrorImageInHorizontal()
            
            self.imageEditorContrainer.srcImageInput.removeAllTargets()
            self.imageEditorContrainer.srcImageInput = GPUImagePicture(cgImage: mirrorImage.cgImage)
            
            self.setupChain()
            
            self.restoreStroredStatus()
            self.imageEditorContrainer.srcImageInput.processImage {
                self.imageEditorContrainer.srcImage = mirrorImage
            }
            
            let hasChanged = Int(self.adjustEffect.defaultIntensity(for: .mirror))%2 != 0
            self.fundationCollectionView.updateAdjustFundationState(current: .mirror, hidden: hasChanged)
        }
    }
    
}
