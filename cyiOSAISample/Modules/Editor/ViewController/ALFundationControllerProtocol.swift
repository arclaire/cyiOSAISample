//
//  SDFundationControllerProtocol.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/6.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

public protocol ALFundationControllerProtocol {
    var imageEditorContrainer: ALImageEditorContaionerProtocol {get set}
    init(imageEditContainer: ALImageEditorContaionerProtocol)
    var parameters: Dictionary<String, Any> {get set}
   
    func functionDidLoad()
    func functionWillAppear(animation: Bool)
    func functionDidAppear()
    func functionWillRemove()
    
    func didCancelClick()
    func didConfirmClick()
    
    func didShareClick()
    
    func didEntranceVipPage()
    
    func onSuccessPurchaseVIP()
    func onDismissVIP()
    
    func onRetryConnection()
    
    func onImageTouchMoveBegin(_ point: CGPoint, force: CGFloat, frame: CGRect)
    func onImageTouchMoveTo(_ point: CGPoint, force: CGFloat, frame: CGRect)
    func onImageTouchMoveEnd(_ point: CGPoint, force: CGFloat, frame: CGRect)
    func didImageDoubleTapAt(_ point: CGPoint, frame: CGRect)
    func didImageTapBeganAt(_ point: CGPoint?)
    func didImageTapEndedAt(_ point: CGPoint?)
    func didImageContentFrameChanged(_ newFrame: CGRect, newScale: CGFloat)
    
    func getImageAreaViewHeight(isAppearing: Bool, _ marginBottom: CGFloat) -> CGFloat
    
}
