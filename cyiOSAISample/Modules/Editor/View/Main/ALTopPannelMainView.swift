//
//  SDTopPannelMainView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/7.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class ALTopPannelMainView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializerData()
        configureHierarchyView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var returnBtn: UIButton = {
        let returnBtn = UIButton()
        returnBtn.setImage(UIImage(named: "common_back"), for: .normal)
        
        return returnBtn
    }()
    
    lazy var savingBtn: UIButton = {
        let savingBtn = UIButton()
        savingBtn.setImage(UIImage(named: "common_save"), for: .normal)
        
        return savingBtn
    }()
}

extension ALTopPannelMainView {
    private func initializerData() {
    }
}

extension ALTopPannelMainView {
    private func configureHierarchyView() {
        addSubview(returnBtn)
        addSubview(savingBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        returnBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(37)
            make.top.equalTo(16.adaptBangS())
            make.width.height.equalTo(30)
        }
        
        savingBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(-37)
            make.top.equalTo(16.adaptBangS())
            make.width.height.equalTo(30)
        }
    }
}
