//
//  SDProcessFailedView.swift
//  cyiOSAISample
//
//  Created by Kevin Lee on 14/04/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//


import Foundation

@objc public enum ProcessFailedType: Int {
    case connection
    case apiprocess
    case requirements
}

protocol SDProcessFailedViewDelegate: NSObjectProtocol {
    func doRetry()
    func doCancel()
}

class SDProcessFailedView: UIView {
    private weak var delegate: SDProcessFailedViewDelegate?
    
    private var failedType: ProcessFailedType?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(19)
        label.textColor = UIColor.init(red: 249, green: 75, blue: 185)
        label.numberOfLines = 2
        let attributedString = NSMutableAttributedString(string: "Process Failed")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.5
        paragraphStyle.alignment = .center
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range:NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString

        return label
    }()
    
    private lazy var lblInfo: UILabel = {
        let label = UILabel()
        //label.font = UIFont(name: "Gotham-Black", size: 18)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center

        return label
    }()
    
    let btnRetry : UIButton = {
        let button = UIButton.init()
        button.addTarget(self, action: #selector(doRetry), for: .touchUpInside)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.frame = CGRect(x: 0, y: 0, width: 126, height: 43)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.init(red: 141, green: 80, blue: 216).cgColor, UIColor.init(red: 238, green: 96, blue: 154).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 126, height: 43)
        button.layer.addSublayer(gradientLayer)
        let txt = UILabel()
        txt.text = "Retry"
        txt.font = UIFont(name: "Gotham-Black", size: 18)
        txt.textColor = .white
        button.addSubview(txt)
        txt.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        return button
    }()
    
    let btnCancel : UIButton = {
        let button = UIButton.init()
        button.addTarget(self, action: #selector(doCancel), for: .touchUpInside)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor.init(red: 199, green: 199, blue: 199)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont(name: "Gotham-Black", size: 18)
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    let btnOK : UIButton = {
        let button = UIButton.init()
        button.addTarget(self, action: #selector(doCancel), for: .touchUpInside)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.frame = CGRect(x: 0, y: 0, width: 110, height: 50)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.init(red: 141, green: 80, blue: 216).cgColor, UIColor.init(red: 238, green: 96, blue: 154).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 110, height: 50)
        button.layer.addSublayer(gradientLayer)
        let txt = UILabel()
        txt.text = "asd"
        //txt.font = UIFont(name: "Gotham-Black", size: 18)
        txt.textColor = .white
        button.addSubview(txt)
        txt.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        return button
    }()
    
    convenience init(parent: UIViewController, failedType: ProcessFailedType) {
        self.init(frame: parent.view.bounds)
        
        self.failedType = failedType
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.frame = parent.view.bounds
        blurEffectView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissBlurView(gesture:))))
        
        if failedType == .connection {
            lblInfo.text = "Connection failed "//SDMutableLanguages.Editor.ProcessFailedInfoConnection
        } else if failedType == .apiprocess {
            lblInfo.text = "Fail Processing"
        } else if failedType == .requirements {
            lblInfo.text = "Invalid Requirements"
               // SDMutableLanguages.Editor.ProcessFailedInfoRequirements
        }
        
        self.addSubview(blurEffectView)
        
        addViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if failedType == .connection {
            setConnectionConstraints()
        } else if failedType == .apiprocess {
            setAPIProcessConstraints()
        } else if failedType == .requirements {
            setRequirementsConstraints()
        }
    }
}

extension SDProcessFailedView {
    static func show(parent: UIViewController, delegate: SDProcessFailedViewDelegate, failedType: ProcessFailedType) {
        let view = SDProcessFailedView.init(parent: parent, failedType: failedType)
        view.delegate = delegate
        view.tag = 201
        parent.view.addSubview(view)
    }
    
    static func close(parent: UIViewController) {
        for view in parent.view.subviews {
            if view.tag == 201 {
                view.removeFromSuperview()
            }
        }
    }
}

extension SDProcessFailedView {
    private func addViews() {
        addSubview(contentView)
        contentView.addSubview(lblTitle)
        contentView.addSubview(lblInfo)
        if failedType == .connection {
            contentView.addSubview(btnRetry)
            contentView.addSubview(btnCancel)
        } else {
            contentView.addSubview(btnOK)
        }
    }
    
    private func setConnectionConstraints() {
        lblTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(52)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        lblInfo.snp.makeConstraints { (make) in
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        
        btnRetry.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-60)
            make.leading.equalToSuperview().offset(27)
            make.size.equalTo(CGSize(width: 126, height: 43))
        }
        
        btnCancel.snp.makeConstraints { (make) in
            make.bottom.equalTo(btnRetry)
            make.trailing.equalToSuperview().offset(-27)
            make.size.equalTo(CGSize(width: 126, height: 43))
        }
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(335)
        }
    }
    
    private func setAPIProcessConstraints() {
        lblTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(52)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        lblInfo.snp.makeConstraints { (make) in
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        
        btnOK.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 110, height: 50))
        }
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(335)
        }
    }
    
    private func setRequirementsConstraints() {
        lblTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(52)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        lblInfo.snp.makeConstraints { (make) in
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        
        btnOK.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 110, height: 50))
        }
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(335)
        }
    }
}

extension SDProcessFailedView {
    @objc private func doRetry() {
        if let delegate = self.delegate {
            delegate.doRetry()
        }
    }
    
    @objc private func doCancel() {
        if let delegate = self.delegate {
            delegate.doCancel()
        }
    }
    
    @objc private func dismissBlurView(gesture: UITapGestureRecognizer){
        if let delegate = self.delegate {
            delegate.doCancel()
        }
    }
}

