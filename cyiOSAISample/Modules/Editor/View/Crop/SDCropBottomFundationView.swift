//
//  SDCropBottomFundationView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/13.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit


// MARK: -

@objc protocol SDCropBottomFundationViewDelegate: NSObjectProtocol {
    func didSelectedCropLayoutInCropBottomView(crop layout: SDCropEffectModel)
    
    func rotateAngleBeginDraging()
    func rotateAngleAtLayoutInCropBottomView(rotate angle: CGFloat)
    func rorateAngleEndDraging()
}

@objc protocol SDCropBottomFundationViewDatasource: NSObjectProtocol {
    func cropLayoutInCropBottomFundationView() -> [SDCropItem]
}


private let IdentiferCropBottomCell = "IdentiferCropBottomCell"

class SDCropBottomFundationView: UIView {
    
    // MARK: - Property
    
    weak var cropBottomFundationViewDelegate: SDCropBottomFundationViewDelegate?
    weak var cropBottomFundationViewDatasource: SDCropBottomFundationViewDatasource?
    
    private var cropLayouts: [SDCropItem] = []
    private var selectedIndex: Int = -1
    
    // MARK: - Life Cycle
    
    init(frame: CGRect, delegate: NSObject) {
        super.init(frame: frame)
        
        cropBottomFundationViewDelegate = delegate as? SDCropBottomFundationViewDelegate
        cropBottomFundationViewDatasource = delegate as? SDCropBottomFundationViewDatasource
        
        initializerData()
        configureHierarchyView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lazying View
    
    lazy var cropLayoutCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 50, height: 60)
        flowLayout.minimumLineSpacing = (SDConstants.UI.Screen_Width - 30*2 - 50*6)/5
        
        let cropLayoutCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cropLayoutCollectionView.register(SDCropBottomFundationViewCell.self, forCellWithReuseIdentifier: IdentiferCropBottomCell)
        cropLayoutCollectionView.showsHorizontalScrollIndicator = false
        cropLayoutCollectionView.delegate = self
        cropLayoutCollectionView.dataSource = self
        
        return cropLayoutCollectionView
    }()
    
    lazy var rulerView: RulerView = {
        let size = CGSize(width: SDConstants.UI.Screen_Width, height: 30)
        let rulerView = RulerView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        //刻度高度
        rulerView.shortScaleLength = 6
        rulerView.longScaleLength = 8
        //刻度宽度
        rulerView.scaleWidth = 1
        //刻度起始位置
        rulerView.shortScaleStart = rulerView.frame.size.height - rulerView.shortScaleLength
        rulerView.longScaleStart = rulerView.frame.height - rulerView.longScaleLength
        //刻度颜色
        rulerView.scaleColor = UIColor.RGB(r: 227, g: 227, b: 227)
    
        //刻度之间的距离
        rulerView.distanceBetweenScale = 4
        //刻度距离数字的距离
        rulerView.distanceFromScaleToNumber = 6
        //指示视图属性设置
        rulerView.pointSize = CGSize(width: 2, height: 12)
        rulerView.pointColor = UIColor(hex: "ff2a9b")
        rulerView.pointStart = rulerView.frame.height - rulerView.pointSize.height;
        //文字属性
        rulerView.numberFont = UIFont.systemFont(ofSize: 12)
        rulerView.numberColor = UIColor.RGB(r: 227, g: 227, b: 227)
        //数字所在位置方向
        rulerView.numberDirection = .numberTop
        
        //取值范围
        rulerView.max = 10
        rulerView.min = -10
        //默认值
        rulerView.defaultNumber = 0
        //使用小数类型
        rulerView.isDecimal = true
        //选中
        rulerView.selectionEnable = true
        rulerView.showSelectedValue = false
        
        rulerView.tag = 0
        rulerView.delegate = self
        
        return rulerView
    }()
}


// MARK: - Public Method


// MARK: - Private Method


// MARK: -InitializerData

extension SDCropBottomFundationView {
    func initializerData() {
        if let crops = cropBottomFundationViewDatasource?.cropLayoutInCropBottomFundationView() {
            self.cropLayouts = crops
        }
        
    }
    
    func reset() {
        selectedIndex = -1
        
        for i in 0..<cropLayouts.count {
            cropLayouts[i].isSelected = false
        }
        
        cropLayoutCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate & UICollectionVieDatasource

extension SDCropBottomFundationView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cropLayouts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cropCell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentiferCropBottomCell, for: indexPath) as? SDCropBottomFundationViewCell {
            cropCell.cropItem = self.cropLayouts[indexPath.row]
            
            return cropCell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cropLayouts[indexPath.row].isSelected = true
        
        for i in 0..<cropLayouts.count {
            if i == indexPath.row {
            } else {
                cropLayouts[i].isSelected = false
            }
        }
        
        selectedIndex = indexPath.row
        
        cropBottomFundationViewDelegate?.didSelectedCropLayoutInCropBottomView(crop: SDCropEffectModel.crop(row: indexPath.row))
        
        cropLayoutCollectionView.reloadData()
        self.rulerView.reset()
    }
    
}


// MARK: - RulerViewDelegate

extension SDCropBottomFundationView: RulerViewDelegate {
    func rulerSelectValue(_ value: Double, tag: Int) {
        let rotateAngle = value/10 * Double.pi/2
        
        print("value: \(value) rotate angle: \(rotateAngle)")
        cropBottomFundationViewDelegate?.rotateAngleAtLayoutInCropBottomView(rotate: CGFloat(rotateAngle))
    }
    
    func rulerWillBeginDragging(_ ruler: RulerView!) {
        cropBottomFundationViewDelegate?.rotateAngleBeginDraging()
    }
    
    func rulerDidEndDragging(_ ruler: RulerView!) {
        cropBottomFundationViewDelegate?.rorateAngleEndDraging()
    }
    
}


// MARK: -ConfigureHierarchyView

extension SDCropBottomFundationView {
    func configureHierarchyView() {
        addSubview(self.cropLayoutCollectionView)
        //addSubview(self.rulerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cropLayoutCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(70)
        }
        
//        rulerView.snp.makeConstraints { (make) in
//            make.top.equalTo(cropLayoutCollectionView.snp.bottom)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(30)
//        }
    }
    
}


// MARK: - SDCropBottomFundationViewCell

class SDCropBottomFundationViewCell: UICollectionViewCell {
    
//        titleLab.textColor = UIColor.RGB(r: 249, g: 75, b: 185)
//    }else {
//        titleLab.textColor = UIColor.RGB(r: 255, g: 255, b: 255)

    var cropItem: SDCropItem? {
        didSet {
            guard let item = cropItem else { return }
            if item.isSelected {
                cropIcon.image = item.selectedImage
                cropTitle.textColor = UIColor.RGB(r: 249, g: 75, b: 185)
            } else {
                cropIcon.image = item.image
                cropTitle.textColor = UIColor.RGB(r: 255, g: 255, b: 255)
            }
            cropTitle.text = item.title
            
        }
    }
    
    private var cropIcon: UIImageView = {
           let iconItem = UIImageView()
           iconItem.contentMode = .center
           
           return iconItem
       }()
       
       private var cropTitle: UILabel = {
           let titleItem = UILabel()
           titleItem.font = UIFont.systemFont(ofSize: 15, weight: .regular)
           titleItem.textAlignment = .center
           titleItem.textColor = UIColor.RGB(r: 255, g: 255, b: 255)
        
           return titleItem
       }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cropIcon)
        addSubview(cropTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cropIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalTo(self.snp.centerX)
            make.width.height.equalTo(40)
        }
        
        cropTitle.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(17)
        }
    }
    
}
