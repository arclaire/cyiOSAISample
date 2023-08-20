//
//  CameraViewController.swift
//  cyiOSAISample
//
//  Created by Michael on 09/09/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit
import AVFoundation


@objc public enum CameraType: Int {
    case normal    //four fundations in top view
    case aging     //only three fundations in top view
    case younger   //only three fundations in top view
    case glitch    //only three fundations in top view without face image
    case art       //only three fundations in top view without face image
    case cutout    //only three fundations in top view without face image
    case stickers  //only three fundations in top view without face image
    case anime     //only three fundations in top view without face image
    case hairstyle     //only three fundations in top view without face image
    case frame
    case colorize
    case machineLearning
}

class ALCameraViewController: UIViewController {
   
    
    var isSubscription: Bool = false
    private var faceHandler: SDFaceHandler!
    private var cameraType: CameraType = .normal
    
    private var isDisAppear: Bool = false
    private var isCaputring: Bool = false
    
    private var delayShootTime: CGFloat = 0
    
    private var lookupPic: GPUImagePicture?
    private var cropFilter: GPUImageCropFilter!
    private var lookFilter: GPUImageLookupFilter?
    private var simpleFilter: GPUImageFilter!
    private var beautyFilter : SDGPUImageHighPassSkinSmoothingFilter!
    private var beautifyFilter : SDGPUImageBeautifyFilter!
    private var lookupEffectsFilter: GPUImageFilterGroup = GPUImageFilterGroup()
    
    var modelArtSelected: ALArtModel?
    private var faceTimerCount: Int = 0
    private var faceTimer: Timer!
    
    private var isSupported: Bool = true
    
    private var ratioImage: CGFloat = SDConstants.UI.Screen_Height/SDConstants.UI.Screen_Width
    
    private var kFlashType: FlashType = .off
    
    private var shareImage: UIImage?
    
    private var isCounting = false
    
    private var deviceOrientation: UIDeviceOrientation?
    private var screenSize: ScreenSizeType = .full
    var isCategorySelected: Bool = false
    private var shouldInitializedCamera: Bool = true
    
   
    init(cameraType: CameraType) {
        super.init(nibName: nil, bundle: nil)
        
        self.cameraType = cameraType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialzierData()
        configureHeriarchy()
        
        if self.cameraType == .younger || self.cameraType == .anime {
            if self.isSubscription {
                self.topView.returnBtn.isHidden = true
            }
        }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldInitializedCamera {
            initializerDefaultCamera()
        } else {

            self.startCamera()
            shouldInitializedCamera = true
        }
        
        registerCameraAuth()
        
        isDisAppear = false
        
        observeGenerationDeviceOrientationNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isDisAppear = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: "UserDenyPermissionAgain"), object: nil)
        removeObserveGenerationDeviceOrientationNotifications()
        
        //fix glitching for retake
//        self.removeFilterTarget()
        //end of fix
        
//        clickCancelFundationInFilterItemView()
        
        self.gpuCamera.stopCapture()
    }
    
    deinit {
        self.faceTimer.fire()
       // self.removePurchaseSuccessNotification()
    }
    
    // MARK: - Lazying View
    
    lazy var testView: UIView = {
        let testView = UIView()
        //testView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        testView.backgroundColor = .red
        testView.center = self.view.center
        
        return testView
    }()
    
    lazy var topView: ALCameraTopView = {
        var topView: ALCameraTopView
        if cameraType == .normal {
            topView = SDNormalCameraTopView.init(frame: CGRect(x: 0, y: -70.adaptBangS(), width: SDConstants.UI.Screen_Width, height: 70.adaptBangS()))
        }else {
            topView = SDAgingCameraTopView.init(frame: CGRect(x: 0, y: -70.adaptBangS(), width: SDConstants.UI.Screen_Width, height: 70.adaptBangS()))
        }
        
        topView.topviewDelegate = self
        return topView
    }()
    
    lazy var bottomView: ALCameraBottomView = {
        var bottomView: ALCameraBottomView
        
        if self.cameraType == .normal {
            bottomView = SDNormalCameraBottomView.init(frame: CGRect(x: 0, y: SDConstants.UI.Screen_Height - 26 - SDConstants.UI.Screen_Bottom - 70, width: SDConstants.UI.Screen_Height, height: 70.adaptScreenWidth()))
        }else {
            bottomView = SDFewerCameraBottomView.init(frame: CGRect(x: 0, y: SDConstants.UI.Screen_Height - 26 - SDConstants.UI.Screen_Bottom - 70, width: SDConstants.UI.Screen_Height, height: 70.adaptScreenWidth()))
        }
        
        bottomView.bottomViewDelegate = self
        return bottomView
    }()
    
    lazy var previewView: GPUImageView = {
        let previewView = GPUImageView.init(frame: CGRect(x: 0, y: 0, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height))
        
        previewView.fillMode = .preserveAspectRatioAndFill
        previewView.backgroundColor = .gray
        previewView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return previewView
    }()
    
    lazy var gpuCamera: GPUImageStillCamera = {
        
        var sessionPreset = AVCaptureSession.Preset.hd1280x720
        if !self.supportHightCaptureSessionPressetWithPosition(position: .front) {
            sessionPreset = AVCaptureSession.Preset.vga640x480
        }
        
        guard let camera = GPUImageStillCamera(sessionPreset: sessionPreset.rawValue, cameraPosition: AVCaptureDevice.Position.back) else {
            return GPUImageStillCamera()
        }
        camera.outputImageOrientation = UIInterfaceOrientation.portrait
        camera.horizontallyMirrorFrontFacingCamera = true
        camera.horizontallyMirrorRearFacingCamera = false
        camera.delegate = self
        
        return camera
    }()
    
    lazy var gradCameraView: ALCameraGradView = {
        let gradCameraView = ALCameraGradView(inView: self.previewView)
        
        return gradCameraView
    }()
    
    lazy var agingOldImageV: UIImageView = {
        let agingOldImageV = UIImageView()
        let image = UIImage(named: "camera_old_aging")
        let offsetY: CGFloat = SDConstants.UI.Is_Iphone_5 || SDConstants.UI.Is_Iphone_6 ? 110 : 218
        agingOldImageV.frame = CGRect(x: (SDConstants.UI.Screen_Width - image!.size.width)/2, y: offsetY, width: image!.size.width, height: image!.size.height)
        agingOldImageV.image = image
        agingOldImageV.contentMode = .scaleAspectFit
        
        return agingOldImageV
    }()
    
    lazy var agingOldToast: UILabel = {
        let view = UILabel()
        let text = "Make Your face inside box"
        let font = UIFont.systemFont(ofSize: 15)
        view.text = text as String
        view.font = font
        view.textColor = .white
        view.numberOfLines = 0
        view.textAlignment = .center
        view.backgroundColor = UIColor.init(hex: "#000000", alpha: 0.5)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        let width = 350.adaptScreenWidth()
        let rect = text.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                     attributes:  [NSAttributedString.Key.font: font],
                                     context: nil)
        let txtWidth = rect.width + 16
        let txtHeight = rect.height + 8
        view.frame = CGRect(x: (self.view.frame.width-txtWidth)/2, y: self.bottomView.frame.origin.y - 40 - txtHeight, width: txtWidth, height: txtHeight)
        return view
    }()
    
    lazy var ratioTopView: UIView = {
        let ratioTopView = UIView()
        ratioTopView.frame = CGRect(x: 0, y: -SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height)
        ratioTopView.backgroundColor = .black
        
        return ratioTopView
    }()
    
    lazy var ratioBottomView: UIView = {
        let ratioBottomView = UIView()
        ratioBottomView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height)
        ratioBottomView.backgroundColor = .black
        
        return ratioBottomView
    }()
    
    lazy var delayShootLab: UILabel = {
        let view = UILabel(frame: self.view.bounds)
        view.font = UIFont.systemFont(ofSize: 100, weight: .regular)
        view.textColor = UIColor.RGB(r: 255, g: 255, b: 255)
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var cameraFocusView: ALCameraFocusView = {
        let cameraFocusView = ALCameraFocusView(frame: CGRect(x: 0, y: 0, width: 60.0, height: 60.0))
        cameraFocusView.isHidden = true
        
        return cameraFocusView
    }()
    
    lazy var sureCameraView: ALSureCameraView = {
        let sureCameraView = ALSureCameraView(frame: CGRect(x: 0, y: 0, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height))
        sureCameraView.sureCameraDelegate = self
        sureCameraView.isHidden = true
        
        return sureCameraView
    }()
}

extension ALCameraViewController {
    private func registerCameraAuth() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        self.stopCamera()
                        self.startCamera()
                    }
                    else {
                        //Show Toast
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else if status == .denied {
            //Show Toast
            NotificationCenter.default.addObserver(self, selector: #selector(userDenyAgain), name: NSNotification.Name.init(rawValue: "UserDenyPermissionAgain"), object: nil)
            //PCAppController.sharedInstance.askPermission(self.view, forPermission: "camera")
        }
    }
    
    @objc func userDenyAgain(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: "UserDenyPermissionAgain"), object: nil)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func startCamera() {
        if isDisAppear {
            return
        }
        
        if !isCaputring {
            DispatchQueue.global(qos: .background).async {
                self.gpuCamera.startCapture()
                DispatchQueue.main.async {
                  
                }
            }
           
        }
        
        isCaputring = true
        self.gpuCamera.resumeCameraCapture()
    }
    
    private func stopCamera() {
        if isCaputring {
            self.gpuCamera.stopCapture()
        }
        
        isCaputring = false
    }
    
    private func supportHightCaptureSessionPressetWithPosition(position: AVCaptureDevice.Position) -> Bool {
        let captureDevice = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position)
        
        for device in captureDevice.devices {
            if !device.supportsSessionPreset(AVCaptureSession.Preset.hd1280x720) {
                return false
            }
        }
        
        return true
    }
    
    private func removeFilterTarget() {
        self.gpuCamera.removeAllTargets()
        self.beautyFilter.removeAllTargets()
        self.beautifyFilter.removeAllTargets()
        self.simpleFilter.removeAllTargets()
        self.cropFilter.removeAllTargets()
        self.lookFilter?.removeAllTargets()
        self.lookupEffectsFilter.removeAllTargets()
        self.lookupEffectsFilter = GPUImageFilterGroup()
        if let `lookupPic` = self.lookupPic {
            lookupPic.removeAllTargets()
        }
        
        self.lookFilter = nil
    }
    
}

extension ALCameraViewController {
    private func takePhotoEvent() {
        var filter: GPUImageFilter
        var filterGroup : GPUImageFilterGroup = self.beautifyFilter
        if self.lookFilter != nil {
            filter = self.lookFilter!
            filterGroup.terminalFilter = filter
        } else {
            if self.lookupEffectsFilter.filterCount() > 0 {
                filterGroup = self.lookupEffectsFilter
            } else {
                filter = self.simpleFilter
                filterGroup = self.beautifyFilter
            }
        }
        
        self.gpuCamera.capturePhotoAsImageProcessedUp(toFilter: filterGroup, with: UIImage.Orientation.up) { (processImage, error) in
            let proImage = processImage?.clipImageWithRatio(ratio: self.ratioImage)
            guard let tmpImage = proImage else { return }
            let rotation = self.getRotation()
            let proImag = rotation == .up ? tmpImage : tmpImage.fixOrientation(orientation: rotation)
            self.shareImage = proImag
            
            //NotificationCenter.default.post(name: Notification.Name.askForReview, object: nil)
            
            //let newImage = proImag.mirrorImageInHorizontal()
            
            if let sampleImg = proImag.resizeWithScaleAspectFitMode(to: SDConstants.IMAGE.desireDimension) {
               
               self.openEditor(ads: .none, image: sampleImg)
               
                //self.sureCameraView.show(original: self.previewView.frame, preview: proImag)
                
                //NotificationCenter.default.post(name: Notification.Name.askForReview, object: nil)
            }
        }
    }
    
    func openEditor(ads: AdverstiseStatus, image: UIImage) {
        self.onImageDidTake()
        
        if let sampleImage = image.resizeWithScaleAspectFitMode(to: SDConstants.IMAGE.desireDimension) {
            if let nav = self.navigationController {
                if self.cameraType == .art {
                    let router: ALRouterEditor = ALRouterEditor(nav: nav)
                    router.create(image: sampleImage, ads: ads, modelArtSelected: self.modelArtSelected)
                } else if self.cameraType == .machineLearning {
                    let vc = CoreMLViewController()
                    vc.imagePassed = image
                    nav.pushViewController(vc, animated: true)
                } else {
                    let router: ALRouterEditor = ALRouterEditor(nav: nav)
                    router.create(image: sampleImage, ads: ads, modelArtSelected: self.modelArtSelected)
                }
                
            } else {
            
            }
        }
        
    }
    
    private func getRotation() -> UIImage.Orientation {
        switch self.deviceOrientation {
        case .landscapeLeft:
            return UIImage.Orientation.left
        case .landscapeRight:
            return UIImage.Orientation.right
        case .portraitUpsideDown:
            return UIImage.Orientation.down
        default:
            return UIImage.Orientation.up
        }
    }
    
    private func syncFlashState() {
        if !self.gpuCamera.inputCamera.isFlashAvailable {
            return
        }
        
        try? self.gpuCamera.inputCamera.lockForConfiguration()
        
        if self.kFlashType == .on {
            self.gpuCamera.inputCamera.flashMode = .on
        }else if self.kFlashType == .off {
            self.gpuCamera.inputCamera.flashMode = .off
        }else if self.kFlashType == .auto {
            self.gpuCamera.inputCamera.flashMode = .auto
        }
        
        self.gpuCamera.inputCamera.unlockForConfiguration()
    }
    
}


// MARK: -

extension ALCameraViewController {
    private func delayShootTakePhotoEvent() {
        var delayTime = delayShootTime
        self.isCounting = true
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler {
            
            DispatchQueue.main.sync {//update in main
                if self.delayShootLab.superview == nil {
                    self.view.addSubview(self.delayShootLab)
                }
                if (delayTime > 0) {
                    self.delayShootLab.text = "\(Int(delayTime))"
                }
            }
            
            delayTime -= 1
            if delayTime < 0 {
                timer.cancel()
                
                self.takePhotoEvent()
                self.isCounting = false
                DispatchQueue.main.async {
                    if self.delayShootLab.superview != nil {
                        self.delayShootLab.removeFromSuperview()
                    }
                }
            }
            
        }
        
        timer.resume()
    }
    
}


// MARK: - View Content(initialzier data | child view | gesture)

extension ALCameraViewController {
    private func initialzierData() {
        view.backgroundColor = .black
       
        self.faceHandler = SDFaceHandler()
        
        self.faceTimer = Timer.init(timeInterval: 5, repeats: true, block: { (timer) in
            self.faceTimerCount = 0
        })
        RunLoop.current.add(self.faceTimer, forMode: .common)
        
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(clickFocusFundationInPreviewView(tap:)))
        self.previewView.addGestureRecognizer(tapGestureRec)
    }
    
    private func initializerDefaultCamera() {
        var hPiexl = 1280
        var wPiexl = 720
        
        if !self.supportHightCaptureSessionPressetWithPosition(position: .front) {
            hPiexl = 640
            wPiexl = 480
        }
        
        var textureSampingSize = CGSize.zero
        let cropScaleSize = CGSize(width: SDConstants.UI.Screen_Width/wPiexl.cgFloat, height: SDConstants.UI.Screen_Height/hPiexl.cgFloat)
        
        if cropScaleSize.height > cropScaleSize.width {
            textureSampingSize.width = SDConstants.UI.Screen_Width / (wPiexl.cgFloat * cropScaleSize.height)
            textureSampingSize.height = 1.0
        }else {
            textureSampingSize.width = 1
            textureSampingSize.height = SDConstants.UI.Screen_Height / (hPiexl.cgFloat * cropScaleSize.width)
        }
        
        let space = (16 - 9)/16
        self.cropFilter = GPUImageCropFilter.init(cropRegion: CGRect(x: 0, y: space/2, width: 1, height: 1 - space))
        //GPUImageCropFilter.init(cropRegion: CGRect(x: (1 - textureSampingSize.width) * 0.5, y: (1 - textureSampingSize.height) * 0.5, width: textureSampingSize.width, height: textureSampingSize.height))
        self.simpleFilter = GPUImageFilter()
        self.beautyFilter = SDGPUImageHighPassSkinSmoothingFilter()
        beautyFilter.amount = 0.4
        
        self.beautifyFilter = SDGPUImageBeautifyFilter()
        
        
        self.gpuCamera.addTarget(self.beautifyFilter)
        self.beautifyFilter.addTarget(self.cropFilter)
        self.cropFilter.addTarget(self.previewView)
        
        DispatchQueue.global(qos: .background).async {
            self.gpuCamera.startCapture()
            DispatchQueue.main.async {
              
            }
        }
       
        
        if self.gpuCamera.inputCamera.isExposurePointOfInterestSupported && self.gpuCamera.inputCamera.isExposureModeSupported(.continuousAutoExposure) {
            try? self.gpuCamera.inputCamera.lockForConfiguration()
            
            self.gpuCamera.inputCamera.exposurePointOfInterest = self.previewView.center
            self.gpuCamera.inputCamera.exposureMode = .continuousAutoExposure
            if self.gpuCamera.inputCamera.isFocusPointOfInterestSupported && self.gpuCamera.inputCamera.isExposureModeSupported(.autoExpose) {
                
                self.gpuCamera.inputCamera.focusPointOfInterest = self.previewView.center
                self.gpuCamera.inputCamera.focusMode = .autoFocus
            }
            
            self.gpuCamera.inputCamera.unlockForConfiguration()
        }
        
        if self.gpuCamera.inputCamera.isFlashActive {
            try? self.gpuCamera.inputCamera.lockForConfiguration()
            
            self.gpuCamera.inputCamera.flashMode = .off
            
            self.gpuCamera.inputCamera.unlockForConfiguration()
            
        }
    }
    
    private func configureHeriarchy() {
        view.addSubview(self.previewView)
        
        
        if !(self.cameraType == .aging) || !(self.cameraType == .younger) || !(self.cameraType == .anime) {
            view.addSubview(self.ratioBottomView)
            view.addSubview(self.ratioTopView)
        }
        
        view.addSubview(self.topView)
       
        view.addSubview(self.bottomView)
        
        if self.cameraType == .aging || self.cameraType == .younger || self.cameraType == .anime {
            view.addSubview(self.agingOldImageV)
            view.addSubview(self.agingOldToast)
        }
        view.addSubview(self.cameraFocusView)
        view.bringSubviewToFront(self.cameraFocusView)
        
        view.addSubview(self.sureCameraView)
        
        view.addSubview(self.testView)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.topView.frame = CGRect(x: 0, y: 0, width: SDConstants.UI.Screen_Width, height: 70.adaptBangS())
        }, completion: nil)
    }
    
}

// MARK: -

extension ALCameraViewController {
    @objc func clickFocusFundationInPreviewView(tap: UITapGestureRecognizer) {
        var point: CGPoint = tap.location(in: self.previewView)
        
        if self.screenSize == .full {
        } else if self.screenSize == .size11 {
            self.ratioImage = 1
            
            let positionY = (SDConstants.UI.Screen_Height - SDConstants.UI.Screen_Width)/2
            point.y = positionY + point.y
        } else if self.screenSize == .size169 {
            self.ratioImage = (9.cgFloat/16.cgFloat)
            
            let height = 9 * SDConstants.UI.Screen_Width / 16
            let positionY = (SDConstants.UI.Screen_Height - height)/2
            point.y = positionY + point.y
        }
        
        cameraFocusView.showAt(point)
        
        self.autoFocusExposureFocusFundation(focus: point, tap: tap)
    }
}

// MARK: - SDGeneratingDeviceOrientationDelegate

extension ALCameraViewController: SDGeneratingDeviceOrientationDelegate {
    
    func handleDeviceOrientationChange(orientation: UIDeviceOrientation) {
        print("================== \(orientation.rawValue)")
        
        self.deviceOrientation = orientation
        
        switch orientation {
        case .landscapeLeft:
            UIView.animate(withDuration: 0.5) {
                self.delayShootLab.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
            }
            
            break
        case .landscapeRight:
            UIView.animate(withDuration: 0.5) {
                self.delayShootLab.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
            }
            
            break

        case .portrait:
            UIView.animate(withDuration: 0.5) {
                self.delayShootLab.transform = CGAffineTransform.init(rotationAngle: 0)
            }
            
            break
            
        case .portraitUpsideDown:
            UIView.animate(withDuration: 0.5) {
                self.delayShootLab.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
            }
            
            break
        
        default:
            break
        }
    }
}

// MARK: - SDCameraViewDelegate

extension ALCameraViewController: SDCameraViewDelegate {
    func clickReturnFundation() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func clickReticleFundationWithType(reticle type: ReticleType) {
        if type == .show {
            gradCameraView.show()
        }else if type == .hide {
            gradCameraView.hide()
        }
    }
    
    func clickFalshFundationWithType(falsh type: FlashType) {
        self.kFlashType = type
        if !gpuCamera.inputCamera.isFlashAvailable {
            return
        }
        
        try? self.gpuCamera.inputCamera.lockForConfiguration()
        
        if type == .on {
            self.gpuCamera.inputCamera.flashMode = .on
        } else if type == .off {
            self.gpuCamera.inputCamera.flashMode = .off
        } else if type == .auto {
            self.gpuCamera.inputCamera.flashMode = .auto
        }
        
        self.gpuCamera.inputCamera.unlockForConfiguration()
    }
    
    func clickTimerFundationWithType(timer type: TimerType) {
        if type == .s0 {
            delayShootTime = 0
        }else if type == .s3 {
            delayShootTime = 3
        }else if type == .s5 {
            delayShootTime = 5
        }else if type == .s10 {
            delayShootTime = 10
        }
    }
}

extension ALCameraViewController: GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        if let `lookupPicture` = self.lookupPic {
            lookupPicture.processImage()
        }
        
        if faceTimerCount < 1 {
            var picCopy: CMSampleBuffer?
            CMSampleBufferCreateCopy(allocator: kCFAllocatorDefault, sampleBuffer: sampleBuffer, sampleBufferOut: &picCopy)
            self.processWithSampleBuffer(buffer: CFBridgingRetain(picCopy) as! CMSampleBuffer)
            
            self.faceTimerCount = 1
        }
    }
    
    private func processWithSampleBuffer(buffer: CMSampleBuffer) {
        let faceFeatures = self.faceHandler.facesOutlineFeatureInBuffer(image: buffer, position: self.gpuCamera.cameraPosition())
        
        if let faceFeature = faceFeatures.first {
            let faceRect = SDFaceHandler.faceOutlineCenter(feature: faceFeature, buffer: buffer, parent: self.previewView)
            
            DispatchQueue.main.async {
                self.autoFocusExposureFocusFundation(focus: faceRect)
            }
        }
    }
    
    private func autoFocusExposureFocusFundation(focus point: CGPoint) {
        if self.gpuCamera.inputCamera.isExposurePointOfInterestSupported && self.gpuCamera.inputCamera.isExposureModeSupported(.continuousAutoExposure) {
            
            do {
                try self.gpuCamera.inputCamera.lockForConfiguration()
                
                self.gpuCamera.inputCamera.exposurePointOfInterest = point
                self.gpuCamera.inputCamera.exposureMode = .continuousAutoExposure
                if self.gpuCamera.inputCamera.isFocusPointOfInterestSupported &&
                    self.gpuCamera.inputCamera.isFocusModeSupported(.autoFocus) {
                    self.gpuCamera.inputCamera.focusPointOfInterest = point
                    self.gpuCamera.inputCamera.focusMode = .autoFocus
                }
                
                self.gpuCamera.inputCamera.unlockForConfiguration()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func autoFocusExposureFocusFundation(focus point: CGPoint, tap: UITapGestureRecognizer) {
        var touchPoint = point
        
        if self.gpuCamera.cameraPosition() == .back {
            touchPoint = CGPoint(x: touchPoint.y / (tap.view?.bounds.size.height)!, y: 1-touchPoint.x / (tap.view?.bounds.size.width)!)
        } else {
            touchPoint = CGPoint(x: touchPoint.y / (tap.view?.bounds.size.height)!, y: touchPoint.x / (tap.view?.bounds.size.width)!)
        }
        
        if self.gpuCamera.inputCamera.isExposurePointOfInterestSupported && self.gpuCamera.inputCamera.isExposureModeSupported(.continuousAutoExposure) {
            
            do {
                try self.gpuCamera.inputCamera.lockForConfiguration()
                
                self.gpuCamera.inputCamera.exposurePointOfInterest = touchPoint
                self.gpuCamera.inputCamera.exposureMode = .continuousAutoExposure
                if self.gpuCamera.inputCamera.isFocusPointOfInterestSupported &&
                    self.gpuCamera.inputCamera.isFocusModeSupported(.autoFocus) {
                    self.gpuCamera.inputCamera.focusPointOfInterest = touchPoint
                    self.gpuCamera.inputCamera.focusMode = .autoFocus
                }
                
                self.gpuCamera.inputCamera.unlockForConfiguration()
            } catch let error {
                print(error)
            }
        }
    }
}

// MARK: - SDCameraBottomViewDelegate

extension ALCameraViewController: SDCameraBottomViewDelegate {
    func clickShowFilterFundation(showType type: ShowFilterType) {
        
    }
    
    func clickShowFilterEffectsFundation(showType type: ShowEffectsType) {
        
    }
    
    func clickAlbumFundation() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func clickSwitchCameraFundation(position type: CameraPositionType) {
        SDCameraSwitchVisualViewController.show(parent: self)
        
        self.gpuCamera.rotateCamera()
        self.syncFlashState()
    }
    
    func clickTakePhotoFundation() {
        guard !self.isCounting else {
            return
        }
        self.bottomView.takePhotoBtn.isEnabled = false
        if delayShootTime != 0 {
            delayShootTakePhotoEvent()
        } else {
            takePhotoEvent()
        }
    }
    
    func clickScreenSizeFundation(screenSize type: ScreenSizeType) {
        let gradCameraState: Bool = !gradCameraView.isHidden
        
        self.screenSize = type
        
        if gradCameraState {
            gradCameraView.hide()
        }
        
        let previewSize = self.gainPreviewViewWithScreenSize(screenSize: type)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.ratioTopView.frame = CGRect(x: 0, y: previewSize.origin.y - SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: self.ratioTopView.frame.height)
            self.ratioBottomView.frame = CGRect(x: 0, y: previewSize.size.height + previewSize.origin.y, width: SDConstants.UI.Screen_Width, height: self.ratioBottomView.frame.height)
        }) { (bool) in
            if gradCameraState {
                self.gradCameraView.show()
            }
            if bool {
                UIView.animate(withDuration: 0.3, animations: {
                    self.previewView.frame = self.gainPreviewViewWithScreenSize(screenSize: type)
                }) { (bool) in
                }
            }
        }
    }
       
    private func gainPreviewViewWithScreenSize(screenSize type: ScreenSizeType) -> CGRect {
        if type == .full {
            self.ratioImage = SDConstants.UI.Screen_Height/SDConstants.UI.Screen_Width
            
            return CGRect(x: 0, y: 0, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height)
            
        }else if type == .size11 {
            self.ratioImage = 1
            
            let positionY = (SDConstants.UI.Screen_Height - SDConstants.UI.Screen_Width)/2
            return CGRect(x: 0, y: positionY, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Width)
            
        }else if type == .size169 {
            self.ratioImage = (9.cgFloat/16.cgFloat)
            
            let height = 9 * SDConstants.UI.Screen_Width / 16
            let positionY = (SDConstants.UI.Screen_Height - height)/2
            return CGRect(x: 0, y: positionY, width: SDConstants.UI.Screen_Width, height: height)
            
        }
        return .zero
    }
}


extension ALCameraViewController: ALSureCameraViewDelegate {
    func sizeOfPreviewInCameraView() -> CGRect {
        return .zero
    }
    
    func clickReturnInSureCamera() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func clickDownloadInSureCamera() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.sureCameraView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height)
        }) { (bool) in
            self.sureCameraView.frame = CGRect(x: 0, y: 0, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height)
            self.sureCameraView.isHidden = true
        }
        
//        let singleView = SDSingleToastView.init(frame: CGRect(x: 0, y: 0, width: 180, height: 32))
//        singleView.show(parent: self)
//
        self.lookupPic?.enabled = false
        self.removeFilterTarget()
        self.initializerDefaultCamera()
       
        
        self.clickFalshFundationWithType(falsh: self.kFlashType)
    }
    
    func clickReTakePhotoInSureCamera() {
        self.lookupPic?.enabled = false
        self.removeFilterTarget()
        self.initializerDefaultCamera()
        //let retakephoto = SDRetakePhotoToastView.init(frame: CGRect(x: 0, y: 0, width: 189, height: 128))
        //retakephoto.show(parent: self)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.sureCameraView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height)
        }) { (bool) in
            self.sureCameraView.frame = CGRect(x: 0, y: 0, width: SDConstants.UI.Screen_Width, height: SDConstants.UI.Screen_Height)
            self.sureCameraView.isHidden = true
        }
        
        self.clickFalshFundationWithType(falsh: self.kFlashType)
    }
    
    func clickSharePhotoInSureCamera() {
        let items = [shareImage]
        let sharePage = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        self.navigationController?.present(sharePage, animated: true, completion: {
            
        })
    }
    
    func clickEditorPhotoInSureCamera(_ image: UIImage?) {
        guard let img = image else { return }
        
        if let sampleImage = img.resizeWithScaleAspectFitMode(to: SDConstants.IMAGE.desireDimension) {
//            if let editorPage = FYRouter.shareInstance()?.Editor_ShowMainPage(img, image: sampleImage) {
//                self.show(editorPage, sender: nil)
//            }
        }
    }
    
    func onImageDidTake() {
        self.bottomView.takePhotoBtn.isEnabled = true
    }
}

extension ALCameraViewController {
    func entranceVipPage() {
        //SDPopupVIPView.show(parent: self, delegate: self, specificView: self.view)
    }
    
    func removeVipPage() {
        for view in self.view.subviews {
            if view.tag == 101 {
                view.removeFromSuperview()
            }
        }
    }
}
