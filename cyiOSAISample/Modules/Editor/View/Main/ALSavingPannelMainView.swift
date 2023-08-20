//
//  SDSavingPannelMainView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/14.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit


// MARK: -

@objc protocol ALSavingPannelMainViewDelegate: NSObjectProtocol {
    func clickReturnFundationInSavingMainView()
    func clickShareFundationInSavingMainView()
    func clickHomeFundationInSavingMainView()
}

@objc protocol ALSavingPannelMainViewDataSource: NSObjectProtocol {
    
}


class ALSavingPannelMainView: UIView {
    
    // MARK: - Property
    
    override var isHidden: Bool {
        didSet {
            if !isHidden {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.toastLabel.isHidden = true
                }
            }
        }
    }
    
    weak var pannelMainViewDelegate: ALSavingPannelMainViewDelegate?
    weak var pannelMainViewDataSource: ALSavingPannelMainViewDataSource?
    
    
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
    
    lazy var returnBtn: UIButton = {
        let returnBtn = UIButton()
        returnBtn.setImage(UIImage(named: "common_back"), for: .normal)
        returnBtn.addTarget(self, action: #selector(clickReturnButton), for: .touchUpInside)
        
        return returnBtn
    }()
    
    lazy var shareBtn: UIButton = {
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage(named: "common_share"), for: .normal)
        shareBtn.addTarget(self, action: #selector(clickShareButton), for: .touchUpInside)
        shareBtn.isHidden = true
        return shareBtn
    }()
    
    lazy var editorImageV: UIImageView = {
        let editorImageV = UIImageView()
        editorImageV.contentMode = .scaleAspectFit
        editorImageV.isHidden = false
        return editorImageV
    }()
    
    lazy var toastLabel: UILabel = {
        let toastLabel = UILabel()
        toastLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        toastLabel.backgroundColor = UIColor.RGB(r: 0, g: 0, b: 0)
        toastLabel.textColor = UIColor.white
        toastLabel.text = "Image Saved"
        toastLabel.alpha = 0.7
        toastLabel.layer.cornerRadius = 6
        toastLabel.layer.masksToBounds = true
        toastLabel.textAlignment = .center
        
        return toastLabel
    }()
    
    lazy var homeReturn: UIButton = {
        let homeReturn = UIButton()
        homeReturn.addTarget(self, action: #selector(clickHomeButton), for: .touchUpInside)
        homeReturn.setImage(UIImage(named: "common_home"), for: .normal)
        homeReturn.setTitleColor(.white, for: .normal)
        homeReturn.layer.cornerRadius = 9
        homeReturn.backgroundColor = UIColor.init(rgb: 0x232323)
        homeReturn.isHidden = true
        return homeReturn
    }()
}


// MARK: - Public Method


// MARK: - Private Method

extension ALSavingPannelMainView {
    @objc private func clickReturnButton() {
        pannelMainViewDelegate?.clickReturnFundationInSavingMainView()
    }
    
    @objc private func clickShareButton() {
        pannelMainViewDelegate?.clickShareFundationInSavingMainView()
        
        let interfaceModule = "Edit Page"
        let component = "Share button"
        let description = "Share button after editing photo"
        let eventId = "edit_share"
        let showName = "edit.page.share"
        let eventType = "Calculation event"
        
        //SDAnalyticsManager.count(eventId: eventId, attributes: ["interfaceModule": interfaceModule, "component": component, "description": description, "showName": showName, "eventType": eventType])
    }
    
    @objc private func clickHomeButton() {
        pannelMainViewDelegate?.clickHomeFundationInSavingMainView()
    }
    
}


// MARK: -InitializerData

extension ALSavingPannelMainView {
    private func initializerData() {
        self.backgroundColor = .white
    }
    
}


// MARK: -ConfigureHierarchyView

extension ALSavingPannelMainView {
    private func configureHierarchyView() {
        addSubview(returnBtn)
        addSubview(shareBtn)
        addSubview(editorImageV)
        addSubview(toastLabel)
        addSubview(homeReturn)
        
        //toastLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        returnBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.top.equalTo(0.adaptBangS())
//            make.top.equalTo(16.adaptBangS())
//            make.top.equalToSuperview().offset(40.adaptNotBangS())
            make.width.height.equalTo(48)
        }
        
        shareBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-37)
            make.top.equalToSuperview().offset(16.adaptBangS())
//            make.top.equalTo(16.adaptBangS())
//            make.top.equalToSuperview().offset(40.adaptNotBangS())
            make.width.height.equalTo(30)
        }
        
        toastLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(snp.centerX)
            make.bottom.equalToSuperview().offset(-270)
            make.width.equalTo(240)
            make.height.equalTo(32)
        }
        
        editorImageV.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(returnBtn.snp.bottom).offset(20)
            make.bottom.equalTo(homeReturn.snp.top).offset(-30)
        }
        
        homeReturn.snp.makeConstraints { (make) in
            make.centerX.equalTo(snp.centerX)
            make.bottom.equalToSuperview().offset(-30)
            make.width.equalTo(60)
            make.height.equalTo(70)
        }
        
    }
    
}
