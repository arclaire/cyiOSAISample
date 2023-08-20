//
//  SDBottomPannelMainView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/7.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

public struct SDMainFundationModule {
    var editFundation: SDImageEditFundation
    var iconName: String = ""
    var fundationName: String = ""
    var isVip: Bool
}

// MARK: -

protocol SDBottomPannelMainViewDelegate: NSObjectProtocol {
    func bottomPannelView(didSelected fundationModule: SDMainFundationModule)
}

protocol SDBottomPannelMainViewDataSource: NSObjectProtocol {
    func fundationModulesInBottomPannelView() -> [SDMainFundationModule]
}

private let IdentifierBottomCollectionCell = "IdentifierBottomCollectionCell"


class ALBottomPannelMainView: UIView {
    
    // MARK: - Property
    
    weak var filterItemViewDelegate: SDBottomPannelMainViewDelegate?
    weak var filterItemViewDataSource: SDBottomPannelMainViewDataSource?
    
    private var fundationModules: [SDMainFundationModule] = []
    
    
    // MARK: - Life Cycle
    
    init(delegate: NSObject) {
        super.init(frame: .zero)
        
        self.filterItemViewDelegate = delegate as? SDBottomPannelMainViewDelegate
        self.filterItemViewDataSource = delegate as? SDBottomPannelMainViewDataSource
        
        if let modules = self.filterItemViewDataSource?.fundationModulesInBottomPannelView() {
            fundationModules = modules
        }
        
        addSubview(self.fundationCollectionView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(self.fundationCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fundationCollectionView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(70)
        }
    }
    
    
    // MARK: - Lazying View
    
    lazy var fundationCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 60, height: 70)
        flowLayout.minimumLineSpacing = (SDConstants.UI.Screen_Width - 60*6)/6
        flowLayout.minimumInteritemSpacing = (SDConstants.UI.Screen_Width - 60*6)/6
        flowLayout.scrollDirection = .horizontal
        
        let fundationCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        fundationCollectionView.register(SDBottomCollectionViewCell.self, forCellWithReuseIdentifier: IdentifierBottomCollectionCell)
        fundationCollectionView.showsHorizontalScrollIndicator = false
        fundationCollectionView.delegate = self
        fundationCollectionView.dataSource = self
        
        return fundationCollectionView
    }()
}


// MARK: - Public Method


// MARK: - Private Method


// MARK: -InitializerData


// MARK: -ConfigureHierarchyView


// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension ALBottomPannelMainView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fundationModules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierBottomCollectionCell, for: indexPath) as! SDBottomCollectionViewCell
        
        if indexPath.row < fundationModules.count {
            cell.fundationModule = fundationModules[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < fundationModules.count, self.filterItemViewDelegate != nil {
            self.filterItemViewDelegate?.bottomPannelView(didSelected: fundationModules[indexPath.row])
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
    }
    
}


// MARK: - SDBottomCollectionViewCell

class SDBottomCollectionViewCell: UICollectionViewCell {
    var fundationModule: SDMainFundationModule? {
        didSet {
            fundationIconImageV.image = UIImage(named: fundationModule!.iconName)
            fundationTitleLab.text = fundationModule?.fundationName
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(fundationIconImageV)
        addSubview(fundationTitleLab)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fundationIconImageV.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        fundationTitleLab.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(14)
        }
    }
    
    
    // MARK: - Lazying
    lazy var fundationIconImageV: UIImageView = {
        let fundationIconImageV = UIImageView()
        fundationIconImageV.contentMode = .center
        
        return fundationIconImageV
    }()
    
    lazy var fundationTitleLab: UILabel = {
        let fundationTitleLab = UILabel()
        fundationTitleLab.font = UIFont.systemFont(ofSize: 10, weight: .light)
        fundationTitleLab.textAlignment = .center
        fundationTitleLab.textColor = .white
        return fundationTitleLab
    }()
}

