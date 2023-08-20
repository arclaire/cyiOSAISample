//
//  SDSureCameraView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/10/31.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit
import SnapKit


// MARK: -

@objc protocol ALSureCameraViewDelegate: NSObjectProtocol {
    func sizeOfPreviewInCameraView() -> CGRect
    
    func clickReturnInSureCamera()
    func clickDownloadInSureCamera()
    func clickReTakePhotoInSureCamera()
    func clickSharePhotoInSureCamera()
    func clickEditorPhotoInSureCamera(_ image: UIImage?)
    
    func onImageDidTake()
}


class ALSureCameraView: UIView {
    
    // MARK: - Property
    
    weak var sureCameraDelegate: ALSureCameraViewDelegate?
    
    private var hasSavedImageEnable: Bool = false
    
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializerData()
        configureHierarchyView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lazying View
    
    lazy var returnBth: UIButton = {
        let returnBth = UIButton()
        returnBth.setImage(UIImage(named: "common_cancel"), for: .normal)
        returnBth.addTarget(self, action: #selector(clickReturnButton), for: .touchUpInside)
        
        return returnBth
    }()
    
    lazy var sharePhotoBtn: UIButton = {
        let sharePhotoBtn = UIButton()
        sharePhotoBtn.setImage(UIImage(named: "common_share"), for: .normal)
        sharePhotoBtn.addTarget(self, action: #selector(clickShareButton), for: .touchUpInside)
        
        return sharePhotoBtn
    }()
    
    lazy var previewImageV: UIImageView = {
        let previewImageV = UIImageView()
        previewImageV.image = UIImage(named: "common_download")
        previewImageV.contentMode = .scaleAspectFit
        
        return previewImageV
    }()
    
    lazy var retakePhotoBtn: UIButton = {
        let retakePhotoBtn = UIButton()
        retakePhotoBtn.setImage(UIImage(named: "common_camera"), for: .normal)
        retakePhotoBtn.setTitle("Retake", for: .normal)
        retakePhotoBtn.addTarget(self, action: #selector(clickRetakePhotoButton), for: .touchUpInside)
        retakePhotoBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .light)
        retakePhotoBtn.titleLabel?.textAlignment = .center
        retakePhotoBtn.imageEdgeInsets = UIEdgeInsets(top: 9, left: 15, bottom: 31, right: 15)
        retakePhotoBtn.titleEdgeInsets = UIEdgeInsets(top: 49, left: -28, bottom: 9, right: 0)
        
        return retakePhotoBtn
    }()
    
    lazy var downloadBtn: UIButton = {
        let downloadBtn = UIButton()
        downloadBtn.setImage(UIImage(named: "common_download"), for: .normal)
        downloadBtn.addTarget(self, action: #selector(clickSaveButton), for: .touchUpInside)
        downloadBtn.layer.cornerRadius = 9
        downloadBtn.layer.masksToBounds = true
        downloadBtn.backgroundColor = UIColor.RGB(r: 35, g: 35, b: 35)
        
        return downloadBtn
    }()
    
    lazy var editorBtn: UIButton = {
        let editorBtn = UIButton()
        editorBtn.setImage(UIImage(named: "common_magic_stick"), for: .normal)
        editorBtn.setTitle("Edit", for: .normal)
        editorBtn.addTarget(self, action: #selector(clickEditorButton), for: .touchUpInside)
        editorBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .light)
        editorBtn.titleLabel?.textAlignment = .center
        editorBtn.imageEdgeInsets = UIEdgeInsets(top: 9, left: 15, bottom: 31, right: 15)
        editorBtn.titleEdgeInsets = UIEdgeInsets(top: 49, left: -28, bottom: 9, right: 0)
        
        return editorBtn
    }()
    
    lazy var sucessSaveTitleLab: UILabel = {
        let sucessSaveTitleLab = UILabel()
        sucessSaveTitleLab.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        sucessSaveTitleLab.textColor = .white
        sucessSaveTitleLab.backgroundColor = .black
        sucessSaveTitleLab.alpha = 0.7
        sucessSaveTitleLab.isHidden = true
        sucessSaveTitleLab.text = "saved"
        
        return sucessSaveTitleLab
    }()
}


// MARK: - Public Method

extension ALSureCameraView {
    func show(original frame: CGRect, preview image: UIImage) {
        self.isHidden = false
        previewImageV.frame = frame
        previewImageV.image = image
        let height = SDConstants.UI.Screen_Height - 87.adaptNotBangS() - 140
        let curFrame = CGRect(x: 0, y: 87.adaptNotBangS(), width: SDConstants.UI.Screen_Width, height: height)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.previewImageV.frame = curFrame
        }, completion: { (success) in
            self.sureCameraDelegate?.onImageDidTake()
        })
    }
    
}


// MARK: - Private Method

extension ALSureCameraView {
    @objc private func clickReturnButton() {
        if let delegate = sureCameraDelegate {
            if !hasSavedImageEnable {
                
            }
            
            delegate.clickReturnInSureCamera()
        }
    }
    
    @objc private func clickSaveButton() {
        SDPhotoManager.sharedInstance.saveImageIntoAlbum(image: previewImageV.image!) { (result, error) in
            if result, let delegate = self.sureCameraDelegate {
                DispatchQueue.main.async {
                    delegate.clickDownloadInSureCamera()
                }
            }
        }
    }
    
    @objc private func clickRetakePhotoButton() {
        if let delegate = sureCameraDelegate {
            delegate.clickReTakePhotoInSureCamera()
        }
    }
    
    @objc private func clickShareButton() {
        if let delegate = sureCameraDelegate {
            delegate.clickSharePhotoInSureCamera()
        }
        
        let interfaceModule = "Camera Page"
        let component = "Share button"
        let description = "Share button after capturing photo"
        let eventId = "camera_share"
        let showName = "camera.page.share"
        let eventType = "Calculation event"
        
       
    }
    
    @objc private func clickEditorButton() {
        if let delegate = sureCameraDelegate {
            delegate.clickEditorPhotoInSureCamera(previewImageV.image)
        }
    }
}


// MARK: -InitializerData

extension ALSureCameraView {
    private func initializerData() {
        self.backgroundColor = .black
    }
}


// MARK: -ConfigureHierarchyView
extension ALSureCameraView {
    private func configureHierarchyView() {
        addSubview(returnBth)
        addSubview(sharePhotoBtn)
        //addSubview(giveLikeLab)
        addSubview(previewImageV)
        addSubview(sucessSaveTitleLab)
        
        addSubview(retakePhotoBtn)
        addSubview(downloadBtn)
        addSubview(editorBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        returnBth.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(40.adaptNotBangS())
//            make.top.equalTo(16.adaptBangS())
            make.top.equalToSuperview().offset(16.adaptBangS())
            make.left.equalToSuperview().offset(37)
            make.width.height.equalTo(30.adaptScreenWidth())
        }
        
        sharePhotoBtn.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(40.adaptNotBangS())
//            make.top.equalTo(16.adaptBangS())
            make.top.equalToSuperview().offset(16.adaptBangS())
            make.right.equalToSuperview().offset(-37)
            make.width.height.equalTo(30.adaptScreenWidth())
        }
        
        sucessSaveTitleLab.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp_centerX)
            make.width.equalTo(220)
            make.height.equalTo(32)
            make.top.equalTo(149.adaptNotBangS() + 494.adaptNotBottomS().adaptScreenWidth())
        }
        
        let padding = (SDConstants.UI.Screen_Width - 60.adaptScreenWidth() * 3.cgFloat)/4
        
        retakePhotoBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-49.adaptNotBottomS())
            make.left.equalToSuperview().offset(padding)
            make.width.equalTo(60.adaptScreenWidth())
            make.height.equalTo(70.adaptScreenWidth())
        }
        
        downloadBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-49.adaptNotBottomS())
            make.centerX.equalTo(snp.centerX)
            make.width.equalTo(60.adaptScreenWidth())
            make.height.equalTo(70.adaptScreenWidth())
        }
        
        editorBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-49.adaptNotBottomS())
            make.right.equalToSuperview().offset(-padding)
            make.width.equalTo(60.adaptScreenWidth())
            make.height.equalTo(70.adaptScreenWidth())
        }
    }
}

