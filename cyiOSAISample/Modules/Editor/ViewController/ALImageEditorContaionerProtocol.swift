//
//  SDImageEditorContaionerProtocol.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/6.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation
import UIKit


public struct SDVerticalSize {
    var topOffset: CGFloat
    var height: CGFloat
    
    static let  zero = SDVerticalSize(topOffset: 0.0, height: 0.0)
}

public protocol ALImageEditorContaionerProtocol: NSObjectProtocol {
    var fundationTitle: String {get set}
    var titleHidden: Bool {get set}
    
    var confirmButtonEnable: Bool {get set}
    var bottomPanelHidden: Bool {get set}
    var isScaleEnable: Bool {get set}
    var controllPanelHeight: CGFloat {get}
    var safeAreaContainer: UIView {get}
    var rootView: UIView {get}
    var visibleContentView: UIView {get}
    var scrollView: UIScrollView {get}
    var renderView: GPUImageView {get}
    var transform3d: CATransform3D {get set}
    
    var contentViewFrame: CGRect {get}
    var contentLimitArea: CGRect {get}
    
    var realUndoManager: UndoManager? {get}
    
    func resizeImageArea(newSize: SDVerticalSize, duration: TimeInterval, animated: Bool)
    
    func switchFundation(to fundation: SDImageEditFundation) -> Bool
    func returnPreFundation()
    func finish(byChanel: Bool)
    
    var srcImage: UIImage {get set}
    var srcImageInput: GPUImagePicture {get set}
    
    func showOriginal()
    func showEffected()
    
    func pushTo(_ viewController: UIViewController)
    func openModal(_ viewController: UIViewController)
    func dismissStackTopVC()
    
    func presentToIAP(tab: String, pkName: String)
    func presentToIAP(tab: String, entrance: String, pkName: String)
    func gotoGrandingGuidance(_ entrance: String)
    func showError()
    
    func openLoadingPage()
    func closeLoadingPage()
    
    func didEntranceVipPage()
    func removeVipPage()
    
    func openProcessFailedPage(failedType: ProcessFailedType)
    func closeProcessFailedPage()
    func setFundationTitle(text: String)
}
