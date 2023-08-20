//
//  SDBaseFundationController.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/6.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

let editorAnimationTime = 0.30

class ALBaseFundationController: NSObject, ALFundationControllerProtocol {
    
    var imageEditorContrainer: ALImageEditorContaionerProtocol
    
    required init(imageEditContainer: ALImageEditorContaionerProtocol) {
        self.imageEditorContrainer = imageEditContainer
    }
    
    var parameters: Dictionary<String, Any> = [:]
    
    func functionDidLoad() {
        
    }
    
    func functionWillAppear(animation: Bool) {
        
    }
    
    func functionDidAppear() {
        
    }
    
    func functionWillRemove() {
        
    }
    
    func didCancelClick() {
        imageEditorContrainer.showOriginal()
    }
    
    func didConfirmClick() {
        
    }
    
    func didShareClick() {
        
    }
    
    func didEntranceVipPage() {
        
    }
    
    func onSuccessPurchaseVIP() {
        
    }
    
    func onDismissVIP() {
        
    }
    
    func onRetryConnection() {
    }
    
    func removeVipPage(){
        
    }
    
    func onImageTouchMoveBegin(_ point: CGPoint, force: CGFloat, frame: CGRect) {
        
    }
    
    func onImageTouchMoveTo(_ point: CGPoint, force: CGFloat, frame: CGRect) {
        
    }
    
    func onImageTouchMoveEnd(_ point: CGPoint, force: CGFloat, frame: CGRect) {
        
    }
    
    func didImageDoubleTapAt(_ point: CGPoint, frame: CGRect) {
        
    }
    
    func didImageTapBeganAt(_ point: CGPoint?) {
        
    }
    
    func didImageTapEndedAt(_ point: CGPoint?) {
        
    }
    
    func didImageContentFrameChanged(_ newFrame: CGRect, newScale: CGFloat) {
        
    }
    
    func getImageAreaViewHeight(isAppearing: Bool, _ marginBottom: CGFloat = 0.0) -> CGFloat {
        
        let height = imageEditorContrainer.safeAreaContainer.frame.size.height - topPannelViewHeight
        
        if (isAppearing) {
            if marginBottom != 0.0 {
                return height - bottomControllPanelHeight - fundationHeight + marginBottom
            } else {
                return height - bottomControllPanelHeight - fundationHeight - 10
            }
        } else {
            if marginBottom != 0.0 {
                return height - fundationHeight + marginBottom
            } else {
                return height - fundationHeight
            }
        }
    }
}
