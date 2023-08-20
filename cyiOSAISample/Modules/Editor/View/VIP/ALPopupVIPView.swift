//
//  SDPopupVIPView.swift
//  cyiOSAISample
//
//  Created by leni santi on 26/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults

protocol ALPopupVIPViewDelegate: NSObjectProtocol {
    func onUpgradeClick(button: UIButton)
    func onDismiss()
}

class ALPopupVIPView: UIView {
    private weak var delegate: ALPopupVIPViewDelegate?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var headerImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage.init(named: "subscription_popup_icon")
        return imageview
    }()
    
    private lazy var text: UILabel = {
        let view = UILabel()
        view.text = "cyiOSAISample".localized
        view.font = UIFont(name: "Gotham Black", size: 30)
        view.textColor = UIColor.init(red: 33, green: 33, blue: 33)
        view.textAlignment = .center
        return view
    }()
    
    private lazy var desc: UILabel = {
        let view = UILabel()
        view.text = "text_popup_subtitle".localized
        view.font = UIFont(name: "Gotham", size: 17)
        view.textColor = UIColor.init(red: 255, green: 133, blue: 22)
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .custom)
        view.frame = CGRect(x: 0, y: 0, width: 246, height: 65)
        view.addTarget(self, action: #selector(onBtnClick(btn:)), for: .touchUpInside)
        view.layer.cornerRadius = 32.5
        view.layer.masksToBounds  = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.init(red: 255, green: 171, blue: 25).cgColor, UIColor.init(red: 255, green: 133, blue: 22).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 246, height: 65)
        view.layer.addSublayer(gradientLayer)
        let txt = UILabel()
        txt.text = "text_upgrade_now".localized
        txt.font = UIFont(name: "Gotham Black", size: 20)
        txt.textColor = .white
        view.addSubview(txt)
        txt.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var btnClose: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage(named: "common_cancel"), for: .normal)
        button.alpha = 0.7
        button.addTarget(self, action:#selector(self.closePressed(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private static var offsetTop: CGFloat = 0
    
    static func show(parentView: UIView, delegate: ALPopupVIPViewDelegate?, specificView: UIView?, offsetTopView: CGFloat = 0) {
        offsetTop = offsetTopView
        let view = ALPopupVIPView(parent: parentView)
        view.delegate = delegate
        view.tag = 101
        parentView.addSubview(view)
    }
    
    static func show(parent: UIViewController, delegate: ALPopupVIPViewDelegate?, specificView: UIView?, offsetTopView: CGFloat = 0) {
        offsetTop = offsetTopView
        let view = ALPopupVIPView.init(parent: parent)
        view.delegate = delegate
        view.tag = 101
        if specificView == nil {
            parent.view.addSubview(view)
        } else {
            specificView?.addSubview(view)
        }
    }
    
    convenience init(parent view: UIView) {
        self.init(frame: view.bounds)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.frame = view.bounds
        self.addSubview(blurEffectView)
        
        addViews()
    }
    
    convenience init(parent: UIViewController) {
        self.init(frame: parent.view.bounds)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.frame = parent.view.bounds
        self.addSubview(blurEffectView)
        addViews()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setConstraints()
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        
        //Defaults[.closeButton] = true
    }
    
    func addViews() {
        self.addSubview(contentView)
        contentView.addSubview(headerImageView)
        contentView.addSubview(text)
        contentView.addSubview(desc)
        contentView.addSubview(button)
        //if Defaults[.closeButton] {
            contentView.addSubview(btnClose)
        //}
    }
    
    private func setConstraints() {
        headerImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(166.6)
        }
        
        text.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerImageView.snp_bottom).offset(9.4)
        }
        
        desc.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(text.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(37)
            make.right.equalToSuperview().offset(-37)
        }
        
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(desc.snp_bottom).offset(10)
            make.size.equalTo(CGSize(width: 246, height: 65))
        }
        
        contentView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(ALPopupVIPView.offsetTop)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(320)
            $0.bottom.equalTo(button.snp_bottom).offset(30)
        }
        
        //if Defaults[.closeButton] {
            btnClose.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.width.equalTo(30)
           // }
        }
    }
    
    @objc private func onBtnClick(btn: UIButton) {
        delegate?.onUpgradeClick(button: btn)
    }
    
    @objc func closePressed(_ sender: UIButton!) {
        delegate?.onDismiss()
    }
}
