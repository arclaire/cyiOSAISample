//
//  SDEffectsItemView.swift
//  cyiOSAISample
//
//  Created by Lucy on 05/12/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation


enum EffectsItemEntrancePage: String {
    case camera = "Camera Page"
    case editor = "Editor page"
}

@objc protocol SDEffectsItemViewDelegate: NSObjectProtocol {
    func doCancelEffects()
    func doSelectedEffects(effectsItem: SDEffectsItem)
    func doSliderChangedEffects(_ sender: UISlider)
}

@objc protocol SDEffectsItemViewDataSource: NSObjectProtocol {
    func filterEffectsModelsInFilterItemView() -> [SDEffectsModel]
    
    func filterDefaultModuleNameInFilterEffectsItemView() -> EffectsCategory
}

class SDEffectsItemView: UIView {
    weak var effectsItemViewDelegate: SDEffectsItemViewDelegate?
    weak var effectsItemViewDataSource: SDEffectsItemViewDataSource?
    
    public var effectsItemEntrancePage: EffectsItemEntrancePage = .camera
    
    private static let IndentiferInEffectsItemViewHeader = "IndentiferInEffectsItemViewHeader"
    private static let IndentiferInEffectsItemViewCell = "IndentiferInEffectsItemViewCell"
    
    private var currentFilterCategory: EffectsCategory = .none
    
    private var selectedSectionState: [Bool] = []
    private var effectsModels: [SDEffectsModel] = []
    private var selectedIndexpath: IndexPath?
    private var indexPathActive: IndexPath?
    
    init(frame: CGRect, delegate: NSObject) {
        super.init(frame: frame)
        
        effectsItemViewDelegate = delegate as? SDEffectsItemViewDelegate
        effectsItemViewDataSource = delegate as? SDEffectsItemViewDataSource
        
        initializerData()
        configureHierarchyView()
        
        unflodFilterItemViewWithFilterCategory(filter: self.currentFilterCategory)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializerData()
        configureHierarchyView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var effectsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.headerReferenceSize = CGSize(width: 60, height: 70)
        flowLayout.itemSize = CGSize(width: 60, height: 70)
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.scrollDirection = .horizontal
        
        let effectsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        effectsCollectionView.register(SDCollectionEffectsHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SDEffectsItemView.IndentiferInEffectsItemViewHeader)
        effectsCollectionView.register(SDCollectionEffectsViewCell.self, forCellWithReuseIdentifier: SDEffectsItemView.IndentiferInEffectsItemViewCell)
        effectsCollectionView.showsHorizontalScrollIndicator = false
        effectsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 0)
        effectsCollectionView.delegate = self
        effectsCollectionView.dataSource = self
        effectsCollectionView.backgroundColor = .clear
        
        return effectsCollectionView
    }()
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.setImage(UIImage(named: "camera_discard"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(clickCancelWithButton), for: .touchUpInside)
        
        return cancelBtn
    }()
    
    lazy var effectsSlider: UISlider = {
        let effectsSlider = UISlider()
        let circleImage = self.makeCircleWith(size: CGSize(width: 20, height: 20), backgroundColor: UIColor.yellow)
        effectsSlider.setThumbImage(circleImage, for: .normal)
        effectsSlider.setThumbImage(circleImage, for: .highlighted)
        effectsSlider.minimumTrackTintColor = UIColor.blue
        effectsSlider.maximumTrackTintColor = .white
        effectsSlider.minimumValue = 0.0
        effectsSlider.maximumValue = 1.0
        
        effectsSlider.addTarget(self, action: #selector(didSliderValueChanged(_:)), for: .valueChanged)
        effectsSlider.addTarget(self, action: #selector(didSliderTouchEnd(_:)), for: .touchCancel)
        effectsSlider.addTarget(self, action: #selector(didSliderTouchEnd(_:)), for: .touchUpInside)
        effectsSlider.addTarget(self, action: #selector(didSliderTouchEnd(_:)), for: .touchUpOutside)
        
        return effectsSlider
    }()
}

extension SDEffectsItemView {
    func unfloderFilterCollectionWithAnimation() {
        if self.currentFilterCategory != .none {
            for index in 0..<self.selectedSectionState.count {
                if self.selectedSectionState[index] {
                    
                    let pointOffset = CGPoint(x:(index * (60 + 5)).cgFloat - 31.cgFloat, y: self.effectsCollectionView.contentOffset.y)
                    self.effectsCollectionView.setContentOffset(pointOffset, animated: true)
                    
                    break
                }
            }
        }
    }
    
    func didSelectFirstFilterInUnfloder(defaultSelected indexPath: IndexPath) {
        let effectsItem = self.effectsModels[indexPath.section].effectsItems[indexPath.row]
        
        effectsItemViewDelegate?.doSelectedEffects(effectsItem: effectsItem)
        
        self.resetEffectsItemCellSelectedState(self.effectsCollectionView, indexPath: indexPath)
    }
}

extension SDEffectsItemView {
    func resetStateEffectsItemView() {
        for index in 0..<self.selectedSectionState.count {
            let isOpen = self.selectedSectionState[index]
            if isOpen {
                for effectsItem in self.effectsModels[index].effectsItems {
                    effectsItem.Selected = false
                }
            }
        }
        
        for index in 0..<effectsModels.count {
            self.selectedSectionState[index] = false
        }
        
        self.effectsCollectionView.reloadData()
    }
    
    func resetSelection() {
        self.resetDataSelected()
        self.effectsSlider.isHidden = true
        self.effectsCollectionView.reloadData()
    }
    
    func reloadCollectionView() {
        self.effectsCollectionView.reloadData()
    }
}

extension SDEffectsItemView {
    private func resetDataSelected() {
        for item in self.effectsModels {
            for subitems in item.effectsItems {
                subitems.Selected = false
            }
        }
    }
    
    private func unflodFilterItemViewWithFilterCategory(filter category: EffectsCategory) {
        if category == .none { return }
        for index in 0..<self.effectsModels.count {
            let filterModel: SDEffectsModel = self.effectsModels[index]
            if (filterModel.category == category) {
                let headerBtn = UIButton()
                headerBtn.tag = index
                self.clickHeaderEventWithButton(sender: headerBtn)
                
                break
            }
        }
    }
}

extension SDEffectsItemView {
    @objc private func clickCancelWithButton() {
        if let delegate = effectsItemViewDelegate {
            delegate.doCancelEffects()
        }
        
        self.resetSelection()
    }
    
    @objc private func clickHeaderEventWithButton(sender: UIButton) {
        for i in 0..<self.selectedSectionState.count {
            if sender.tag == i {
                if selectedSectionState[i] == true {
                    self.selectedSectionState[i] = false
                    
                    let pointOffset = CGPoint(x: self.effectsCollectionView.contentOffset.x, y: self.effectsCollectionView.contentOffset.y)
                    self.effectsCollectionView.setContentOffset(pointOffset, animated: true)
                } else {
                    self.selectedSectionState[i] = true
                    
                    let pointOffset = CGPoint(x: (sender.tag * (60 + 5)).cgFloat - 31.cgFloat, y: self.effectsCollectionView.contentOffset.y)
                    self.effectsCollectionView.setContentOffset(pointOffset, animated: true)
                }
                
            } else {
                self.selectedSectionState[i] = false
            }
            
        }
        self.effectsSlider.isHidden = true
        
        self.effectsCollectionView.reloadData()
    }
    
    @objc func didSliderValueChanged(_ sender: UISlider) {
        effectsItemViewDelegate?.doSliderChangedEffects(sender)
    }
    
    @objc func didSliderTouchEnd(_ sender: UISlider) {
    }
}

extension SDEffectsItemView {
    private func initializerData() {
        self.backgroundColor = .clear
        
        if let filters = effectsItemViewDataSource?.filterEffectsModelsInFilterItemView() {
            self.effectsModels = filters
            
            for index in 0..<filters.count {
                self.selectedSectionState.append(false)
                print("index: \(index)")
            }
        }
        
        if let effectsItemViewDataSource = effectsItemViewDataSource {
            self.currentFilterCategory = effectsItemViewDataSource.filterDefaultModuleNameInFilterEffectsItemView()
        }
    }
}

extension SDEffectsItemView {
    private func configureHierarchyView() {
        addSubview(self.cancelBtn)
        addSubview(self.effectsSlider)
        addSubview(self.effectsCollectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cancelBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        effectsSlider.snp.makeConstraints { (make) in
            make.centerX.equalTo(snp.centerX)
            make.top.equalToSuperview().offset(3.5)
            make.width.equalTo(SDConstants.UI.Screen_Width - 142)
            make.height.equalTo(17)
        }
        
        effectsCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(70)
        }
    }
}

extension SDEffectsItemView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.effectsModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section < self.selectedSectionState.count, self.selectedSectionState[section] {
            return CGSize(width: 50, height: 58)
        } else {
            return CGSize(width: 60, height: 70)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SDEffectsItemView.IndentiferInEffectsItemViewHeader, for: indexPath) as! SDCollectionEffectsHeaderView
            
            headerView.headerBtn.tag = indexPath.section
            headerView.headerBtn.addTarget(self, action: #selector(clickHeaderEventWithButton(sender:)), for: .touchUpInside)
            
            if indexPath.section < self.effectsModels.count, self.effectsModels[indexPath.section].effectsItems.count > 0 {
                if let effectsItem = self.effectsModels[indexPath.section].effectsItems.first {
                    let filterName = effectsItem.Name
                    effectsItem.Name = self.effectsModels[indexPath.section].name
                    
                    headerView.effectsItem = effectsItem
                    
                    effectsItem.Name = filterName
                }
            }
            
            if indexPath.section < self.selectedSectionState.count, self.selectedSectionState[indexPath.section] {
                headerView.headerImageV.isHidden = false
                headerView.headShadowView.isHidden = false
                headerView.layer.cornerRadius = 9
                
            } else {
                headerView.headerImageV.isHidden = true
                headerView.headShadowView.isHidden = true
                headerView.layer.cornerRadius = 7
            }
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            if self.selectedSectionState[section] {
                return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 15)
            }
            
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        }
        
        if section < selectedSectionState.count, !self.selectedSectionState[section - 1], self.selectedSectionState[section] {
            if self.selectedSectionState[section]{
                return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 15)
            }

            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
        
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < self.selectedSectionState.count, self.selectedSectionState[section] {
            if section < self.effectsModels.count {
                return self.effectsModels[section].effectsItems.count
            }
            return 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SDEffectsItemView.IndentiferInEffectsItemViewCell, for: indexPath) as! SDCollectionEffectsViewCell
        if indexPath.section < self.effectsModels.count, indexPath.row < self.effectsModels[indexPath.section].effectsItems.count {
            let effectsItem = self.effectsModels[indexPath.section].effectsItems[indexPath.row]
            cell.effectsItem = effectsItem
            cell.isPremiumArt = effectsItem.IsVip
            //if Utilities.isPurchased() {
                cell.isPremiumArt = false
            //}
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.indexPathActive = indexPath
        if indexPath.section < self.effectsModels.count, indexPath.row < self.effectsModels[indexPath.section].effectsItems.count {
            let effectsItem = self.effectsModels[indexPath.section].effectsItems[indexPath.row]
            
            //SDAnalyticsManager.effectSelect(self.effectsModels[indexPath.section].name, name: effectsItem.Name)
            
            effectsItemViewDelegate?.doSelectedEffects(effectsItem: effectsItem)
            self.resetEffectsItemCellSelectedState(collectionView, indexPath: indexPath)
        }
    }
    
    private func resetEffectsItemCellSelectedState(_ collectionView: UICollectionView, indexPath: IndexPath) {
        let section = indexPath.section
        self.selectedIndexpath = indexPath
        self.resetDataSelected()
        for index in 0..<self.effectsModels[section].effectsItems.count {
            self.effectsModels[section].effectsItems[index].Selected = false
            
            let allIndexPath = IndexPath(row: index, section: section)
            if indexPath == allIndexPath {
                self.effectsModels[section].effectsItems[index].Selected = true
            }
        }
        
        self.effectsCollectionView.reloadData()
    }
}

class SDCollectionEffectsHeaderView: UICollectionReusableView {
    var effectsItem: SDEffectsItem? {
        didSet {
            if let item = effectsItem {
                self.headerBtn.setImage(UIImage(contentsOfFile: item.PreviewImage), for: .normal)
                self.titleLab.text = "effects_\(item.Name.lowercased())".localized(name: "Filters")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.backgroundColor = .clear
        
        addSubview(self.headerBtn)
        addSubview(self.headShadowView)
        addSubview(self.headerImageV)
        addSubview(self.titleShadowView)
        addSubview(self.titleLab)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        headerImageV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        headShadowView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        headerBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleShadowView.snp.makeConstraints { (make) in
            make.trailing.leading.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.trailing.leading.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    lazy var headerImageV: UIImageView = {
        let headerImageV = UIImageView()
        headerImageV.image = UIImage(named: "close_filter")
        headerImageV.isUserInteractionEnabled = false
        
        return headerImageV
    }()
    
    lazy var headShadowView: UIView = {
        let headShadowView = UIView()
        headShadowView.backgroundColor = UIColor.RGB(r: 35, g: 35, b: 35)
        headShadowView.alpha = 0.7
        headShadowView.isHidden = true
        headShadowView.isUserInteractionEnabled = false
        
        return headShadowView
    }()
    
    lazy var headerBtn: UIButton = {
        let headerBtn = UIButton()
        headerBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        headerBtn.imageView?.contentMode = .scaleAspectFit
        
        return headerBtn
    }()
    
    private var titleShadowView: UIView = {
        let titleShadowView = UIView()
        titleShadowView.backgroundColor = UIColor.RGBA(r: 41, g: 41, b: 41, a: 0.5)
        
        return titleShadowView
    }()
    
    lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.textColor = UIColor.RGB(r: 255, g: 255, b: 255)
        titleLab.layer.cornerRadius = 9.0
        titleLab.font = UIFont.systemFont(ofSize: 10, weight: .light)
        titleLab.textAlignment = .center
        
        return titleLab
    }()
    
}

class SDCollectionEffectsViewCell: UICollectionViewCell {
    var selectedEnable: Bool = false {
        didSet {
            selectedImageV.isHidden = !selectedEnable
            selectBackgroundView.isHidden = !selectedEnable
        }
    }
    
    var isPremiumArt: Bool = true {
        didSet{
            vipImageView.isHidden = !isPremiumArt
        }
    }
    
    var effectsItem: SDEffectsItem? {
        didSet {
            if let item = effectsItem {
                previewImageV.image = UIImage(contentsOfFile: item.PreviewImage)
                titleLab.text = item.Name
                selectedImageV.isHidden = !item.Selected
                selectBackgroundView.isHidden = !item.Selected
            }
        }
    }
    
    private var vipImageView: UIImageView = {
        let imageView = UIImageView()
        let vipImage = UIImage.init(named: "subscription_pro_icon")
        imageView.image = vipImage
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 7
        
        addSubview(self.previewImageV)
        addSubview(self.selectBackgroundView)
        addSubview(self.selectedImageV)
        addSubview(self.titleShadowView)
        addSubview(self.titleLab)
        previewImageV.addSubview(self.vipImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewImageV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        selectBackgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        selectedImageV.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(48)
            make.height.equalTo(20)
        }
        
        titleShadowView.snp.makeConstraints { (make) in
            make.trailing.leading.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.trailing.leading.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
        vipImageView.snp.makeConstraints{ (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(13)
            make.width.equalTo(28)
        }
    }
    
    private var previewImageV: UIImageView = {
        let previewImageV = UIImageView()
        
        return previewImageV
    }()
    
    private var selectBackgroundView: UIView = {
        let selectBackgroundView = UIView()
        selectBackgroundView.alpha = 0.4
        selectBackgroundView.backgroundColor = .brown
        selectBackgroundView.isHidden = true
        
        return selectBackgroundView
    }()
    
    private var selectedImageV: UIImageView = {
        let selectedImageV = UIImageView()
        selectedImageV.image = UIImage(named: "camera_selected_filter")
        selectedImageV.isHidden = true
        
        return selectedImageV
    }()
    
    private var titleShadowView: UIView = {
        let titleShadowView = UIView()
        titleShadowView.backgroundColor = UIColor.RGBA(r: 41, g: 41, b: 41, a: 0.5)
        
        return titleShadowView
    }()
    
    private var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.textColor = UIColor.RGB(r: 255, g: 255, b: 255)
        titleLab.backgroundColor = .clear
        titleLab.layer.cornerRadius = 7.0
        titleLab.font = UIFont.systemFont(ofSize: 10, weight: .light)
        titleLab.textAlignment = .center
        
        return titleLab
    }()
}
