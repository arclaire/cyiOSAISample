//
//  SDAdjustFundationConllectView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/11.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class FundationModel: NSObject {
    var fundation: SDFundation = .none
    
    var fundationName: String = ""
    var fundationImageName: String = ""
    
    var hasChangedValue: Bool = false
    var isSelected: Bool = false
    
    init(_ fundation: SDFundation, fundationname: String, fundationimagename: String, hasChangedValue: Bool, isselected: Bool) {
        self.fundation = fundation
        self.fundationName = fundationname
        self.fundationImageName = fundationimagename
        self.hasChangedValue = hasChangedValue
        self.isSelected = isselected
    }
    
}

enum SDFundation: Int {
    case none
    case exposure
    case contrast
    case saturation
    case sharpen
    case hightlight
    case shadow
    case warmth
    case vignette
    case mirror
    case rotate
    case vertical
    case horizontal
    
    static func forEach(body: (SDFundation) -> Void) {
        [exposure, contrast, saturation, sharpen, hightlight, shadow, warmth, vignette, vertical, horizontal].forEach(body)
    }
    
}


// MARK: -

@objc protocol SDAdjustFundationViewDelegate: NSObjectProtocol {
    func didSelectedModelInAdjustFundationView(selectedFundation model: FundationModel) 
}

@objc protocol SDAdjustFundationViewDataSource: NSObjectProtocol {
    func numberAdjustFundationModels() -> [FundationModel]
}


private let IdentifierFundationCollectionViewCell = "IdentifierFundationCollectionViewCell"

class SDAdjustFundationConllectView: UIView {
    
    // MARK: - Property
    
    weak var adjustFundationDelegate: SDAdjustFundationViewDelegate?
    weak var adjustFundationDataSource: SDAdjustFundationViewDataSource?
    
    private var fundationModels: [FundationModel] = []
    
    // MARK: - Life Cycle
    
    init(frame: CGRect, delegate: NSObject) {
        self.adjustFundationDelegate = delegate as? SDAdjustFundationViewDelegate
        self.adjustFundationDataSource = delegate as? SDAdjustFundationViewDataSource
        
        super.init(frame: frame)
        
        if let datasource = self.adjustFundationDataSource {
            fundationModels = datasource.numberAdjustFundationModels()
        }
        
        addSubview(self.fundationCollectionView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        fundationCollectionView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
    }
    
    
    // MARK: - Lazying View
    
    lazy var fundationCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 65, height: 70)
        flowLayout.minimumLineSpacing = 5
        flowLayout.scrollDirection = .horizontal
        
        let fundationCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        fundationCollectionView.register(SDAdjustFundationCollectionViewCell.self, forCellWithReuseIdentifier: IdentifierFundationCollectionViewCell)
        fundationCollectionView.showsHorizontalScrollIndicator = false
        fundationCollectionView.delegate = self
        fundationCollectionView.dataSource = self
        
        return fundationCollectionView
    }()
}


// MARK: - Public Method

extension SDAdjustFundationConllectView {
    func updateAdjustFundationState(current fundation:SDFundation, hidden: Bool) {
        fundationModels.forEach { (fundationModel) in
            if fundationModel.fundation == fundation {
                fundationModel.hasChangedValue = hidden
                
                self.fundationCollectionView.reloadData()
            }
            
        }
    }
    
    func resetAdjustFundationState() {
        fundationModels.forEach { (fundation) in
            fundation.hasChangedValue = false
            fundation.isSelected = false
        }
        
        self.fundationCollectionView.reloadData()
    }
    
}


// MARK: - Private Method


// MARK: -InitializerData


// MARK: -ConfigureHierarchyView


// MARK: -UICollectionViewDelegate & UICollectionViewDatasource

extension SDAdjustFundationConllectView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fundationModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fundationCell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierFundationCollectionViewCell, for: indexPath) as! SDAdjustFundationCollectionViewCell
        if indexPath.row < fundationModels.count {
            fundationCell.fundationModel = fundationModels[indexPath.row]
            
            //print("fundation model name:\(fundationModels[indexPath.row].fundationName), bool:\(fundationModels[indexPath.row].isSelected)")
        }
        
        return fundationCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fundationCell = self.fundationCollectionView.cellForItem(at: indexPath) as! SDAdjustFundationCollectionViewCell
        if indexPath.row < fundationModels.count {
            let fundationModel = fundationModels[indexPath.row]
            fundationModel.isSelected = true
            fundationCell.fundationModel = fundationModel
            
            self.fundationModels[indexPath.row] = fundationModel
            adjustFundationDelegate?.didSelectedModelInAdjustFundationView(selectedFundation: fundationModel)
            
        }
        
        for row in 0..<fundationModels.count {
            let unSelectedIndexpath = IndexPath(row: row, section: indexPath.section)
            if row != indexPath.row {
                let fundationModel = fundationModels[row]
                fundationModel.isSelected = false
                
                if let unSelectedCell = self.fundationCollectionView.cellForItem(at: unSelectedIndexpath) as? SDAdjustFundationCollectionViewCell {
                    unSelectedCell.fundationModel = fundationModel
                }
                
                self.fundationModels[row] = fundationModel
                
                //print("fundation model name:\(fundationModel.fundationName), bool:\(fundationModel.isSelected)")
            }
            
        }
        
        self.fundationCollectionView.reloadData()
        
    }
    
}



// MARK: - SDAdjustFundationCollectionViewCell


class SDAdjustFundationCollectionViewCell: UICollectionViewCell {
    
    var fundationModel: FundationModel? {
        didSet {
            if fundationModel!.isSelected {
                self.fundationIconImageV.image = UIImage(named: "\(fundationModel!.fundationImageName)_pink")
                self.fundationTitleLab.textColor = UIColor.RGB(r: 249, g: 75, b: 185)
                
            }else {
                self.fundationIconImageV.image = UIImage(named: fundationModel!.fundationImageName)
                self.fundationTitleLab.textColor = UIColor.white
                
            }
            
            self.fundationTitleLab.text = fundationModel!.fundationName
            self.fundationHasChangeImageV.isHidden = !fundationModel!.hasChangedValue
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(fundationIconImageV)
        addSubview(fundationTitleLab)
        addSubview(fundationHasChangeImageV)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fundationIconImageV.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        fundationTitleLab.snp.makeConstraints { (make) in
            make.top.equalTo(fundationIconImageV.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(12)
        }
        
        fundationHasChangeImageV.snp.makeConstraints { (make) in
            make.top.equalTo(fundationTitleLab.snp.bottom).offset(6)
            make.centerX.equalTo(self.snp.centerX)
            make.width.height.equalTo(4)
        }
    }
    
    
    // MARK: - Lazying
    
    lazy var fundationIconImageV: UIImageView = {
        let fundationIconImageV = UIImageView()
        fundationIconImageV.contentMode = .scaleToFill
        
        return fundationIconImageV
    }()
    
    lazy var fundationTitleLab: UILabel = {
        let fundationTitleLab = UILabel()
        fundationTitleLab.font = UIFont.systemFont(ofSize: 10, weight: .light)
        fundationTitleLab.textColor = UIColor.RGB(r: 255, g: 255, b: 255)
        fundationTitleLab.textAlignment = .center
        
        return fundationTitleLab
    }()
    
    lazy var fundationHasChangeImageV: UIImageView = {
        let fundationHasChangeImageV = UIImageView()
        fundationHasChangeImageV.backgroundColor = UIColor.RGB(r: 249, g: 75, b: 185)
        fundationHasChangeImageV.layer.masksToBounds = true
        fundationHasChangeImageV.layer.cornerRadius = 2
        fundationHasChangeImageV.isHidden = true
        
        return fundationHasChangeImageV
    }()
}
