//
//  SDMainPageEditorFundationController.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/6.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

private let topPannelOffset = 16.adaptBangS()

class ALMainPageEditorFundationController: ALBaseFundationController {
    private var topPannelView: ALTopPannelMainView!
    private var bottomPannelView: ALBottomPannelMainView!
    
    private var fundationModules: [SDMainFundationModule] = []
    
    private var isSavingImage: Bool = false
    private var safeFlag: Bool = true
    
    // MARK: - Life Cycle
    
    override func functionDidLoad() {
        initializerData()
        configureHeriarchy()
        
        self.topPannelView.isHidden = false
        self.imageEditorContrainer.safeAreaContainer.addSubview(self.topPannelView)
        imageEditorContrainer.resizeImageArea(newSize: SDVerticalSize(topOffset: topPannelViewHeight, height: getImageAreaViewHeight(isAppearing: false, marginRemove)), duration: editorAnimationTime, animated: false)
        marginRemove = 0
    }
    
    override func functionWillAppear(animation: Bool) {
        imageEditorContrainer.isScaleEnable = true
        imageEditorContrainer.titleHidden = true
        imageEditorContrainer.bottomPanelHidden = true
        self.topPannelView.isHidden = false
        if animation {
            UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseIn, animations: {
                self.topPannelView.frame = CGRect(x: 0, y: -0.adaptBangS(), width: SDConstants.UI.Screen_Width, height: topPannelViewHeight)
                self.bottomPannelView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height - bottomPannelViewHeight, width: SDConstants.UI.Screen_Width, height: bottomPannelViewHeight)
                
            }) { (bool) in
                self.safeFlag = true
            }
            
        }else {
            self.topPannelView.frame = CGRect(x: 0, y: -0.adaptBangS(), width: SDConstants.UI.Screen_Width, height: topPannelViewHeight)
            self.bottomPannelView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height - bottomPannelViewHeight, width: SDConstants.UI.Screen_Width, height: bottomPannelViewHeight)
            
            self.safeFlag = true
        }
        
    }
    
    override func functionWillRemove() {
        UIView.animate(withDuration: editorAnimationTime, delay: 0, options: .curveEaseOut, animations: {
            self.topPannelView.frame = CGRect(x: self.topPannelView.frame.origin.x, y: -self.topPannelView.frame.size.height, width: SDConstants.UI.Screen_Width, height: self.topPannelView.frame.height)
            self.bottomPannelView.frame = CGRect(x: self.bottomPannelView.frame.origin.x, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: self.bottomPannelView.frame.height)

        }) { (bool) in
            self.topPannelView.isHidden = false
        }
        
    }
    
    // MARK: -
    
    @objc override func didCancelClick() {
        self.imageEditorContrainer.finish(byChanel: true)
    }
    
    @objc override func didConfirmClick() {
        self.imageEditorContrainer.finish(byChanel: false)
        
    }
    
}

// MARK: - Initialzier & Heriarchy

extension ALMainPageEditorFundationController {
    private func initializerData() {
        self.fundationModules = [
            SDMainFundationModule(editFundation: .crop, iconName: "editor_resize", fundationName: "Edit", isVip: false),
            SDMainFundationModule(editFundation: .adjust, iconName: "editor_adjustment", fundationName: "Edit", isVip: false),
            SDMainFundationModule(editFundation: .artfilter, iconName: "editor_arts", fundationName: "Arts", isVip: false),
            SDMainFundationModule(editFundation: .effect, iconName: "editor_effects", fundationName: "Effect", isVip: false),
            
        ]
    }
    
    private func configureHeriarchy() {
        //-topPannelViewHeight
        topPannelView = ALTopPannelMainView.init(frame: CGRect(x: 0, y: -0.adaptBangS(), width: SDConstants.UI.Screen_Width, height: topPannelViewHeight))
        topPannelView.backgroundColor = .white
        topPannelView.returnBtn.addTarget(self, action: #selector(didCancelClick), for: .touchUpInside)
        topPannelView.savingBtn.addTarget(self, action: #selector(didConfirmClick), for: .touchUpInside)
        
        bottomPannelView = ALBottomPannelMainView.init(delegate: self)
        bottomPannelView.frame = CGRect(x: 0, y: SDConstants.UI.Screen_Height, width: SDConstants.UI.Screen_Width, height: bottomPannelViewHeight)
        bottomPannelView.backgroundColor = .clear
        bottomPannelView.filterItemViewDelegate = self
        bottomPannelView.filterItemViewDataSource = self
        
        self.imageEditorContrainer.safeAreaContainer.addSubview(bottomPannelView)
    }
    
}

// MARK: - SDBottomPannelMainViewDelegate & SDBottomPannelMainViewDataSource

extension ALMainPageEditorFundationController: SDBottomPannelMainViewDelegate, SDBottomPannelMainViewDataSource {
    func fundationModulesInBottomPannelView() -> [SDMainFundationModule] {
        return self.fundationModules
    }
    
    func bottomPannelView(didSelected fundationModule: SDMainFundationModule) {
        guard safeFlag else { return }
        
        safeFlag = false
        safeFlag = !self.imageEditorContrainer.switchFundation(to: fundationModule.editFundation)
        
    }
    
}

// MARK: - SDSavingPannelMainViewDelegate

extension ALMainPageEditorFundationController: ALSavingPannelMainViewDelegate {
    func clickReturnFundationInSavingMainView() {
        self.didCancelClick()
    }
    
    func clickShareFundationInSavingMainView() {
        //NotificationCenter.default.post(name: NSNotification.init(name: "SDShare", object: nil), object: nil)
    }
    
    func clickHomeFundationInSavingMainView() {
        //if let homePage = FYRouter.shareInstance()?.Home_ShowDetailPage() {
            //self.imageEditorContrainer.pushTo(homePage)
        //}
    }
    
}
