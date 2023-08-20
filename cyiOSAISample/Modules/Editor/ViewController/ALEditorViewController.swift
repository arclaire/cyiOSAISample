//
//  SDEditorViewController.swift
//  cyiOSAISample
//
//  Created by admin on 2019/10/28.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

let bottomPannelHeight = 70.adaptNotBottomS()
let adjustRangePanelH = 52.cgFloat
var fundationHeight = 120.cgFloat

let topPannelViewHeight = 90.adaptNotBangS()
let bottomPannelViewHeight = 120.adaptNotBottomS()

var marginRemove = 0.cgFloat

var bottomControllPanelHeight = 48.cgFloat
var paddingBottomPannelHeight = 20.cgFloat

class ALEditorViewController: UIViewController, ALImageEditorContaionerProtocol {
    let primaryButtonSize: CGFloat = 48
    
    private var switchSafeFlag = true
    
    public var initialFundation: SDImageEditFundation? = nil
    public var initialPreFundation: SDImageEditFundation? = nil
    public var initialFundationParameters: Dictionary<String, Any> = [:]
    
    private var preFundation: SDImageEditFundation? = .main
    private var currentFundation: SDImageEditFundation? = .main
    private var currentFundationController: ALFundationControllerProtocol?
    private var functionControllerCache: [SDImageEditFundation: ALFundationControllerProtocol] = [:]
    private var iSInitialized = false
    private var iSInitialing = false
    
    private var initialContentFrame: CGRect = .zero
    private var cacheRect: CGRect = .zero
    
    private var transform3D: CATransform3D!
    
    var isSubscription: Bool
    var modelArt:ALArtModel?
    
    init(originalImage: UIImage, compressedImage: UIImage, isSubscription: Bool = false) {
        self.originalImage = originalImage
        self.srcImage = compressedImage
        self.isSubscription = isSubscription
        self.srcImageInput = GPUImagePicture.init(image: compressedImage)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removePurchaseSuccessNotification()
        //NotificationCenter.default.removeObserver(self, name: .closePlanCEditorPage, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialzierData()
        configureHeriarchy()
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        //added by to delay touch delay on IPhone XS Max
        let window = view.window!
        let gr0 = window.gestureRecognizers![0] as UIGestureRecognizer
        let gr1 = window.gestureRecognizers![1] as UIGestureRecognizer
        gr0.delaysTouchesBegan = false
        gr1.delaysTouchesBegan = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        functionControllerCache.removeAll()
        functionControllerCache[currentFundation!] = currentFundationController
    }
    
    private lazy var bottomControllPanel: UIView = {
        let bottomControllPanel = UIView()
        bottomControllPanel.backgroundColor = .white
        
        return bottomControllPanel
    }()
    
    private lazy var cancelBtn: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setImage(UIImage(named: "common_back"), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        cancelButton.addTarget(self, action: #selector(clickCancelWithButton), for: .touchUpInside)
        //cancelButton.isHidden = true
        return cancelButton
    }()
    
    private lazy var confirmBtn: UIButton = {
        let confirmBtn = UIButton()
        confirmBtn.setImage(UIImage(named: "common_save"), for: .normal)
        confirmBtn.addTarget(self, action: #selector(clickConfirmWithButton), for: .touchUpInside)
        //confirmBtn.isHidden = true
        return confirmBtn
    }()
    
    private lazy var bottomTitleLab: UILabel = {
        let bottomTitleLab = UILabel()
        bottomTitleLab.sizeToFit()
        bottomTitleLab.text = ""
        bottomTitleLab.textColor = .white
        bottomTitleLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        bottomTitleLab.textAlignment = .center
       // bottomTitleLab.isHidden = true
        return bottomTitleLab
    }()
    
    private lazy var safeAreaView: UIView = {
        let safeAreaView = UIView()
        safeAreaView.backgroundColor = .white
        
        return safeAreaView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        
        return contentView
    }()
    
    private lazy var backScrollView: UIScrollView = {
        let backScrollView = UIScrollView.init(frame: .zero)
        backScrollView.delegate = self
        backScrollView.maximumZoomScale = 3.0
        backScrollView.minimumZoomScale = 1.0
        backScrollView.showsVerticalScrollIndicator = false
        backScrollView.showsHorizontalScrollIndicator = false
        
        return backScrollView
    }()
    
    private lazy var innerRenderView: GPUImageView = {
        let innerRenderView = GPUImageView.init(frame: self.view.bounds)
        innerRenderView.fillMode = .stretch
        
        return innerRenderView
    }()
    
    private lazy var savingPannelView: ALSavingPannelMainView = {
        let savingPannelView = ALSavingPannelMainView()
        savingPannelView.isHidden = true
        savingPannelView.pannelMainViewDelegate = self
        
        return savingPannelView
    }()
    
    lazy var blurView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: SDConstants.UI.Screen_Height - topPannelViewHeight - bottomPannelViewHeight))
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    var fundationTitle: String = "" {
        didSet {
            bottomTitleLab.text = fundationTitle
        }
    }
    
    var titleHidden: Bool = false
    
    var confirmButtonEnable: Bool = false
    
    var bottomPanelHidden: Bool = true {
        didSet {
            bottomControllPanel.isHidden = bottomPanelHidden
        }
    }
    
    var isScaleEnable: Bool = false {
        didSet {
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = isScaleEnable ? 3.0: 1.0
        }
    }
    
    var controllPanelHeight: CGFloat {
        return bottomControllPanelHeight
    }
    
    var safeAreaContainer: UIView {
        return safeAreaView
    }
    
    var rootView: UIView {
        return view
    }
    
    var visibleContentView: UIView {
        return contentView
    }
    
    var scrollView: UIScrollView {
        return backScrollView
    }
    
    var renderView: GPUImageView {
        return innerRenderView
    }
    
    var transform3d: CATransform3D {
        get {
            return self.transform3D
        }
        set {
            self.transform3D = newValue
        }
    }
    
    var contentViewFrame: CGRect {
        var frame: CGRect = renderView.frame
        frame = safeAreaContainer.convert(frame, from: backScrollView)
        return frame
    }
    
    var contentLimitArea: CGRect {
        var frame: CGRect = renderView.frame
        frame = safeAreaView.convert(frame, from: backScrollView)
        if frame.minX < 0 {
            frame.origin.x = 0
        }
        if frame.minY < 0 {
            frame.origin.y = 0
        }
        
        return frame
    }
    
    var realUndoManager: UndoManager? {
        return self.undoManager
    }
    
    func resizeImageArea(newSize: SDVerticalSize, duration: TimeInterval, animated: Bool) {
        let scrollViewX = 0
        let scrollViewY = newSize.topOffset
        let scrollViewWidth = SDConstants.UI.Screen_Width
        let scrollViewHeight = newSize.height
        self.scrollView.setZoomScale(1.cgFloat, animated: false)
        self.contentView.snp.remakeConstraints { (make) in
            make.leading.equalTo(scrollViewX)
            make.top.equalTo(scrollViewY)
            make.width.equalTo(scrollViewWidth)
            make.height.equalTo(scrollViewHeight)
        }
        
        if animated {
            UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveLinear, animations: {
                self.setupRenderViewConstraint(scrollViewHeight: newSize.height)
                self.safeAreaContainer.layoutIfNeeded()
            }, completion: nil)
            
        }else {
            self.setupRenderViewConstraint(scrollViewHeight: newSize.height)
        }
        
        self.scrollView.contentSize = CGSize(width: SDConstants.UI.Screen_Width, height: 0)
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func switchFundation(to fundation: SDImageEditFundation) -> Bool {
        guard switchSafeFlag else {
            return false
        }
        
        switchSafeFlag = false
        preFundation = currentFundation
        currentFundation = fundation
        if let currentFundationController = currentFundationController {
            currentFundationController.functionWillRemove()
        }
        var targetController = functionControllerCache[fundation]
        if targetController == nil {
            targetController = fundation.instanceFunctionController(imageEditorContainer: self)
            functionControllerCache[fundation] = targetController
            targetController?.functionDidLoad()
        }
        
        targetController?.functionWillAppear(animation: true)
        targetController?.functionDidAppear()
        currentFundationController = targetController
        
        self.switchSafeFlag = true
        return true
    }
    
    func returnPreFundation() {
        if preFundation != nil {
            let switchFlag = switchFundation(to: preFundation!)
            print("Switch flag: \(switchFlag)")
        }
        
    }
    
    func finish(byChanel: Bool) {
       
        UIImageWriteToSavedPhotosAlbum(srcImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    var originalImage: UIImage
    
    var srcImage: UIImage {
        didSet {
        }
    }
    
    var srcImageInput: GPUImagePicture
    
    func showOriginal() {
        if preFundation == .crop {
            setupRenderViewConstraint(scrollViewHeight: scrollView.bounds.size.height)
        }
        
        DispatchQueue.main.async {
            self.srcImageInput.removeAllTargets()
            self.srcImageInput = GPUImagePicture(image: self.srcImage)
            
            let filter = GPUImageFilter()
            self.srcImageInput.addTarget(filter)
            filter.useNextFrameForImageCapture()
            filter.addTarget(self.renderView)
            
            self.srcImageInput.processImage()
        }
        
    }
    
    func showEffected() {
        if preFundation == .crop {
            setupRenderViewConstraint(scrollViewHeight: scrollView.bounds.size.height)
        }
        
        self.srcImageInput.removeAllTargets()
        self.srcImageInput = GPUImagePicture(image: self.srcImage)
        self.srcImageInput.addTarget(self.renderView)
        self.srcImageInput.processImage()
    }
    
    func openLoadingPage() {
        PCAppController.sharedInstance.openLoadingView(viewController: self)
    }
    
    func closeLoadingPage() {
        PCAppController.sharedInstance.closeLoadingView()
    }
    
    func pushTo(_ viewController: UIViewController) {
        self.show(viewController, sender: nil)
    }
    
    func openModal(_ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func dismissStackTopVC() {
    }
    
    func presentToIAP(tab: String, pkName: String) {
        
    }
    
    func presentToIAP(tab: String, entrance: String, pkName: String) {
        
    }
    
    func gotoGrandingGuidance(_ entrance: String) {
        
    }
    
    func showError() {
        
    }
    
    func didEntranceVipPage() {
        if isSubscription {
           
        } else {
            for view in self.scrollView.subviews {
                if view.tag == 101 {
                    return
                }
            }
            ALPopupVIPView.show(parent: self, delegate: self, specificView: nil)
            //        SDPopupVIPView.show(parentView: self.renderView, delegate: self, specificView: blurView, offsetTopView: -30)
        }
    }
    
    func removeVipPage() {
        for view in self.view.subviews {
            if view.tag == 101 {
                view.removeFromSuperview()
            }
        }
    }
    
    func openProcessFailedPage(failedType: ProcessFailedType) {
        //SDProcessFailedView.show(parent: self, delegate: self, failedType: failedType)
    }
    
    func closeProcessFailedPage() {
        //SDProcessFailedView.close(parent: self)
    }
    
    func setFundationTitle(text: String) {
        //fundationTitle = text
    }
}

extension ALEditorViewController {
    private func initialzierData() {
        view.backgroundColor = .white
        
        marginRemove = 0
        
        self.transform3D = self.innerRenderView.layer.transform
        
        //self.observePurchaseSuccessNotification()
        
       //self.hideKeyboardWhenTappedAround()
    }
    
    @objc func shareImage() {
        self.savingPannelView.isHidden = false
    }
    
    private func configureHeriarchy() {
        view.addSubview(self.safeAreaView)
        
        safeAreaView.addSubview(self.contentView)
        contentView.addSubview(self.backScrollView)
        
        backScrollView.addSubview(self.innerRenderView)
        
        view.addSubview(blurView)
        view.addSubview(self.bottomControllPanel)
        
        safeAreaView.addSubview(self.cancelBtn)
        safeAreaView.addSubview(self.confirmBtn)
        safeAreaView.addSubview(self.bottomTitleLab)
        
        view.addSubview(self.savingPannelView)
        
        safeAreaView.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview()
            make.top.equalToSuperview().offset(0.adaptBangS())
            make.bottom.equalToSuperview().offset(-0.adaptBottoms())
        }
        
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(bottomControllPanel.snp.top)
        }
        
        backScrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bottomControllPanel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(bottomControllPanelHeight.adaptBottoms())
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(primaryButtonSize)
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(primaryButtonSize)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }
        
        bottomTitleLab.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(bottomControllPanelHeight)
            make.center.equalToSuperview()
        }
        
        savingPannelView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if backScrollView.frame != .zero && !iSInitialized && !iSInitialing {
            
            currentFundation = initialFundation ?? currentFundation
            preFundation = initialPreFundation ?? preFundation
            currentFundationController = currentFundation?.instanceFunctionController(imageEditorContainer: self)
            functionControllerCache[currentFundation!] = currentFundationController
            currentFundationController?.parameters = initialFundationParameters
            if let controller = currentFundationController as? ALArtFilterPageFundationEditorController {
                controller.modelArtSelected = self.modelArt
            }
            currentFundationController?.functionDidLoad()
            currentFundationController?.functionWillAppear(animation: false)
            currentFundationController?.functionDidAppear()
            iSInitialing = true
            
            setupGLContext()
            
            iSInitialized = true
        }
    }
    
    func setupRenderViewConstraint(scrollViewHeight height: CGFloat) {
        let imageW = srcImage.size.width
        let imageH = srcImage.size.height
        let backScrollViewH = height
        let backScrollViewW = safeAreaView.frame.width
        
        var renderViewLeft = 0.cgFloat
        var renderViewTop = 0.cgFloat
        var renderViewW = backScrollViewW
        var renderViewH = backScrollViewH
        
        if imageW > 0, imageH > 0, backScrollViewH > 0, backScrollViewW > 0 {
            let scrollViewHWRatio = backScrollViewH / backScrollViewW
            let imageHWRatio = imageH / imageW
            if scrollViewHWRatio > imageHWRatio {
                if imageH > backScrollViewH {
                    renderViewH = backScrollViewW / imageW  * imageH
                    renderViewTop = (backScrollViewH - renderViewH) * 0.5
                } else {
                    if(imageW > backScrollViewW) {
                        let ratio = backScrollViewW/imageW
                        renderViewH = imageH * ratio
                        renderViewTop = (backScrollViewH - renderViewH) * 0.5
                        renderViewLeft = (backScrollViewW - renderViewW) * 0.5
                    }
                    else {
                        renderViewH = imageH
                        renderViewW = imageW
                        renderViewTop = (backScrollViewH - renderViewH) * 0.5
                        renderViewLeft = (backScrollViewW - renderViewW) * 0.5
                    }
                }
            } else {
                if imageW > backScrollViewW {
                    renderViewW = backScrollViewH / imageH * imageW
                    renderViewLeft = (backScrollViewW - renderViewW) * 0.5
                } else {
                    if imageH < backScrollViewH {
                        renderViewH = imageH
                        renderViewW = imageW
                        renderViewTop = (backScrollViewH - renderViewH) * 0.5
                        renderViewLeft = (backScrollViewW - renderViewW) * 0.5
                    } else {
                        let ratio = backScrollViewH / imageH
                        renderViewW = imageW * ratio
                        renderViewTop = (backScrollViewH - renderViewH) * 0.5
                        renderViewLeft = (backScrollViewW - renderViewW) * 0.5
                    }
                    
                }
            }
        }
        
        self.innerRenderView.frame = CGRect(x: renderViewLeft, y: renderViewTop, width: renderViewW, height: renderViewH)
        self.initialContentFrame = self.innerRenderView.frame
    }
}

extension ALEditorViewController {
    private func setupGLContext() {
        self.srcImageInput.removeAllTargets()
        
        let filter = GPUImageFilter()
        self.srcImageInput.addTarget(filter)
        filter.addTarget(self.innerRenderView)
        filter.useNextFrameForImageCapture()
        
        self.srcImageInput.processImage()
        
        self.iSInitialing = false
        
    }
}

extension ALEditorViewController {
    @objc private func clickCancelWithButton() {
        self.navigationController?.popViewController(animated: true)
//        currentFundationController!.didCancelClick()
    }
    
    @objc private func clickConfirmWithButton() {
        //self.finish(byChanel: true)
        currentFundationController!.didConfirmClick()
    }
    
}

extension ALEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return renderView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let Ws = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let Hs = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let W  = renderView.frame.size.width
        let H = renderView.frame.size.height
        var rct = renderView.frame
        rct.origin.x = max((Ws - W)/2, 0)
        rct.origin.y = max((Hs - H)/2, 0)
        renderView.frame = rct
        
        notifyContentFrame()
        
        renderView.transform = CATransform3DGetAffineTransform(self.transform3D).scaledBy(x: scrollView.zoomScale, y: scrollView.zoomScale)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //self.transform3D = renderView.layer.transform
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        notifyContentFrame()
        
        //renderView.transform = CGAffineTransform(translationX: scrollView.scr, y: <#T##CGFloat#>)
        //self.transform3D = scrollView.layer.transform
    }
    
    private func notifyContentFrame(isPresentation: Bool = false) {
        let contentViewFrame = isPresentation ? renderView.layer.presentation()?.frame ?? renderView.frame : renderView.frame
        let contentOffset = isPresentation ? scrollView.layer.presentation()?.bounds.origin ?? scrollView.contentOffset : scrollView.contentOffset
        cacheRect.origin.x = contentViewFrame.origin.x - contentOffset.x
        cacheRect.origin.y = contentViewFrame.origin.y - contentOffset.y + scrollView.frame.minY
        cacheRect.size.width = contentViewFrame.width
        cacheRect.size.height = contentViewFrame.height
        currentFundationController?.didImageContentFrameChanged(cacheRect, newScale: cacheRect.width / initialContentFrame.width)
    }
}

extension ALEditorViewController: ALSavingPannelMainViewDelegate {
    func clickReturnFundationInSavingMainView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func clickShareFundationInSavingMainView() {
        let items = [srcImage]
        let sharePage = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.navigationController?.present(sharePage, animated: true, completion: {
            
        })
        
    }
    
    func clickHomeFundationInSavingMainView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension ALEditorViewController {
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        //if error == nil {
            DispatchQueue.main.async {
                self.savingPannelView.isHidden = false
                self.savingPannelView.editorImageV.image = self.srcImage
            }
            
            
       //}
        
    }
    
    @objc func closePlanC (){
        if let viewControllers = self.navigationController?.viewControllers {
            for vc in viewControllers {
                if vc is HomeViewController {
                    let homeVC = vc as! HomeViewController
                    self.navigationController?.popToViewController(homeVC, animated: true)
                    break
                }
            }
        }
    }
}

extension ALEditorViewController : ALPopupVIPViewDelegate{
    func onUpgradeClick(button: UIButton) {
        
    }
    
    func onDismiss() {
        removeVipPage()
        self.currentFundationController?.onDismissVIP()
    }
}

extension ALEditorViewController: SDVipUserHandler {
    func onPurchased(_ notification: NSNotification) {
        successPurchase()
    }
    
    func onRestore(_ notification: NSNotification) {
        successPurchase()
    }
    
    private func successPurchase() {
        definesPresentationContext = false
        PCAppController.sharedInstance.closeLoadingView()
        self.removeVipPage()
        self.currentFundationController?.onSuccessPurchaseVIP()
        //self.removePurchaseSuccessNotification()
        //NotificationCenter.default.removeObserver(self, name: .closePlanCEditorPage, object: nil)
    }
}

extension ALEditorViewController: SDProcessFailedViewDelegate {
    func doRetry() {
        currentFundationController?.onRetryConnection()
        closeProcessFailedPage()
    }
    
    func doCancel() {
        closeProcessFailedPage()
    }
}
