//
//  SDCropPageEditorFundationController.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/6.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class ALCropPageEditorFundationController: ALBaseFundationController {
    private var adjustEnable: Bool = false
    
    private var bottomControllPanelHeight = 48.cgFloat
    private var cropLayouts: [SDCropItem] = []
    private var currentRatioModel: SDCropEffectModel = .free
    
    private var cropRatioView: SDCropRatioView!
    
    override func functionDidLoad() {
        super.functionDidLoad()
        
        initializerData()
        configureHeriarchy()
    }
    
    override func functionWillAppear(animation: Bool) {
        super.functionWillAppear(animation: animation)
        
//        imageEditorContrainer.scrollView.clipsToBounds = false
        imageEditorContrainer.isScaleEnable = false
        imageEditorContrainer.titleHidden = false
        imageEditorContrainer.bottomPanelHidden = false
        self.cropBottomFundationView.isHidden = false
        
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: true)), duration: editorAnimationTime, animated: animation)
        
        cropRatioView = SDCropRatioView(frame: CGRect(x: 0, y: 0, width: self.imageEditorContrainer.renderView.frame.size.width, height: self.imageEditorContrainer.renderView.frame.size.height))
        imageEditorContrainer.renderView.addSubview(cropRatioView)
        cropRatioView.setNeedsDisplay()
        
        UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseIn, animations: {
            self.cropBottomFundationView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height - self.cropBottomFundationView.frame.height.adaptTabberBottom() - paddingBottomPannelHeight - bottomPannelHeight, width: self.cropBottomFundationView.frame.width, height: self.cropBottomFundationView.frame.height)
        }) { (bool) in
        }
    }
    
    override func functionWillRemove() {
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: false)), duration: editorAnimationTime, animated: true)
        
        self.cropRatioView.isHidden = true
        UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseOut, animations: {
            self.cropBottomFundationView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: self.cropBottomFundationView.frame.width, height: self.cropBottomFundationView.frame.height)
            
        }) { (bool) in
            self.cropBottomFundationView.isHidden = true
            self.cropRatioView.removeFromSuperview()
        }
        
    }
    
    override func didCancelClick() {
        super.didCancelClick()
        
        self.adjustEnable = false
        self.cropBottomFundationView.reset()
        
        imageEditorContrainer.returnPreFundation()
    }
    
    override func didConfirmClick() {
        self.cropBottomFundationView.reset()
        
        if !self.adjustEnable {
            self.imageEditorContrainer.showEffected()
            self.imageEditorContrainer.showOriginal()
            self.imageEditorContrainer.returnPreFundation()
            
            return
        }
        
        guard let cropRect = self.cropRatioView.cropRect else { return }
        
        let cropImage = self.cropTo(srcimage: self.imageEditorContrainer.srcImage, referenceObjectSize: self.imageEditorContrainer.renderView.frame.size, cropRect: cropRect)
        
        guard let cropImages = cropImage else { return }
        
        imageEditorContrainer.srcImage = cropImages
        
        self.imageEditorContrainer.showEffected()
        self.imageEditorContrainer.showOriginal()
        self.imageEditorContrainer.returnPreFundation()
        
        self.adjustEnable = false
    }
    
    lazy var cropBottomFundationView: SDCropBottomFundationView = {
        let cropBottomFundationView = SDCropBottomFundationView(frame: CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: fundationHeight), delegate: self)
        cropBottomFundationView.cropBottomFundationViewDelegate = self
        cropBottomFundationView.cropBottomFundationViewDatasource = self
        return cropBottomFundationView
    }()
}

extension ALCropPageEditorFundationController {
    private func cropTo(srcimage: UIImage, referenceObjectSize: CGSize, cropRect: CGRect) -> UIImage? {
        let ctx = UIGraphicsGetCurrentContext()
        UIGraphicsBeginImageContext(referenceObjectSize)
        ctx?.draw(srcimage.cgImage!, in: CGRect(x: 0, y: 0, width: referenceObjectSize.width, height: referenceObjectSize.height))
        
        let xRatio = cropRect.origin.x / referenceObjectSize.width
        let yRatio = cropRect.origin.y / referenceObjectSize.height
        let positionX = xRatio * srcimage.size.width
        let positionY = yRatio * srcimage.size.height
        let wRatio = cropRect.size.width / referenceObjectSize.width
        let hRatio = cropRect.size.height / referenceObjectSize.height
        let sizeW = wRatio * srcimage.size.width
        let sizeH = hRatio * srcimage.size.height
        let imageRef = srcimage.cgImage?.cropping(to: CGRect(x: positionX, y: positionY, width: sizeW, height: sizeH))
        
        if imageRef == nil { return nil }
        
        let image = UIImage.init(cgImage: imageRef!)
        
        return image
    }
}

extension ALCropPageEditorFundationController {
    private func initializerData() {
//        self.cropLayouts = ["Free", "1:1", "4:5", "3:4", "4:3", "16:9","9:16","3:2","2:3"]

        self.cropLayouts = [SDCropItem.init(title: "Free", image: UIImage(named: "editor_crop_free"), selectedImage: UIImage(named: "editor_crop_free_pink")),
                            SDCropItem.init(title: "1:1", image: UIImage(named: "editor_crop_11"), selectedImage: UIImage(named: "editor_crop_11_pink")),
                            SDCropItem.init(title: "4:5", image: UIImage(named: "editor_crop_45"), selectedImage: UIImage(named: "editor_crop_45_pink")),
                            SDCropItem.init(title: "3:4", image: UIImage(named: "editor_crop_34"), selectedImage: UIImage(named: "editor_crop_34_pink")),
                            SDCropItem.init(title: "4:3", image: UIImage(named: "editor_crop_43"), selectedImage: UIImage(named: "editor_crop_43_pink")),
                            SDCropItem.init(title: "16:9", image: UIImage(named: "editor_crop_169"), selectedImage: UIImage(named: "editor_crop_169_pink")),
                            SDCropItem.init(title: "9:16", image: UIImage(named: "editor_crop_916"), selectedImage: UIImage(named: "editor_crop_916_pink")),
                            SDCropItem.init(title: "3:2", image: UIImage(named: "editor_crop_32"), selectedImage: UIImage(named: "editor_crop_32_pink")),
                            SDCropItem.init(title: "2:3", image: UIImage(named: "editor_crop_23"), selectedImage: UIImage(named: "editor_crop_23_pink")),
                            
        ]
    }
    
    private func configureHeriarchy() {
        imageEditorContrainer.safeAreaContainer.addSubview(self.cropBottomFundationView)
    }
}

extension ALCropPageEditorFundationController: SDCropBottomFundationViewDelegate, SDCropBottomFundationViewDatasource{
    func rotateAngleBeginDraging() {
    }
    
    func rorateAngleEndDraging() {
    }
    
    func rotateAngleAtLayoutInCropBottomView(rotate angle: CGFloat) {
        self.imageEditorContrainer.renderView.transform = CATransform3DGetAffineTransform(self.imageEditorContrainer.transform3d).rotated(by: angle)
    }
    
    func cropLayoutInCropBottomFundationView() -> [SDCropItem] {
        return self.cropLayouts
    }
    
    func didSelectedCropLayoutInCropBottomView(crop layout: SDCropEffectModel) {
        self.adjustEnable = true
        
        self.cropRatioView.isHidden = false
        
        self.currentRatioModel = layout
        self.cropRatioView.ratioInfo = currentRatioModel
    }
}
