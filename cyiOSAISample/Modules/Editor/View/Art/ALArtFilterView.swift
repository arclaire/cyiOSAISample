//
//  SDArtFilterView.swift
//  cyiOSAISample
//
//  Created by Michael on 08/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

@objc protocol SDArtFilterViewDelegate: NSObjectProtocol {
    func doDiscard()
    func doSelect(art: ALArtModel?)
    func doPremium(art: ALArtModel?)
    func onIntensityValueChanged(art: ALArtModel?, value: CGFloat)
    func onHoldCompare(art: ALArtModel?)
    func onUnholdCompare(art: ALArtModel?)
}

@objc protocol SDArtFilterViewDataSource: NSObjectProtocol {
    func artModelsView() -> [ALArtModel]
}

class ALArtFilterView: UIView {
    weak var artFilterViewDelegate: SDArtFilterViewDelegate?
    weak var artFilterViewDataSource: SDArtFilterViewDataSource?
    
    private var artModels: [ALArtModel] = []
    
    var selectedArt: ALArtModel?
    var intensityValue: Float = 1
    
    var isApply: Bool = false {
        didSet {
            
            if let selectedArt = self.selectedArt {
                selectedArt.selected = true
                if selectedArt.apiParams != nil {
                    self.sldIntensity.isHidden = true
                } else {
                    self.sldIntensity.isHidden = !isApply
                }
            }
            self.btnCompare.isHidden = !isApply
            
            if !isApply {
                selectedArt = nil
            }
            if selectedArt != nil{
                if let selectedArt = self.selectedArt {
                    /*
                    if selectedArt.isvip && !Utilities.isPurchased() {
                        self.sldIntensity.isHidden = true
                        self.btnCompare.isHidden = true
                    } else {*/
                        if selectedArt.apiParams != nil {
                            self.sldIntensity.isHidden = true
                        } else {
                            self.sldIntensity.isHidden = !isApply
                        }
                        self.btnCompare.isHidden = !isApply
                    self.artCollectionView.reloadData()
                    //}
                }
            }
        }
    }
    
    init(frame: CGRect, delegate: NSObject) {
        super.init(frame: frame)
        
        artFilterViewDelegate = delegate as? SDArtFilterViewDelegate
        artFilterViewDataSource = delegate as? SDArtFilterViewDataSource
        
        initializeData()
        configureHierarchy()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeData()
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var btnDiscard: UIButton = {
        let btnDiscard = UIButton()
        btnDiscard.setImage(UIImage(named: "editor_discard"), for: .normal)
        btnDiscard.addTarget(self, action: #selector(doDiscard), for: .touchUpInside)
        btnDiscard.isHidden = true
        
        return btnDiscard
    }()
    
    lazy var btnCompare: HoldButton = {
        let btnCompare = HoldButton()
        btnCompare.image = UIImage(named: "art_compare")
        btnCompare.delegate = self
        
        return btnCompare
    }()
    
    lazy var sldIntensity: UISlider = {
        let sldIntensity = UISlider()
        let circleImage = makeCircleWith(size: CGSize(width: 20, height: 20), backgroundColor: UIColor.yellow)
        sldIntensity.setThumbImage(circleImage, for: .normal)
        sldIntensity.setThumbImage(circleImage, for: .highlighted)
        sldIntensity.minimumTrackTintColor = UIColor.green
        sldIntensity.maximumTrackTintColor = .lightGray
        sldIntensity.minimumValue = 0
        sldIntensity.maximumValue = 100
        sldIntensity.value = self.intensityValue * 100
        sldIntensity.isHidden = true
        
        sldIntensity.addTarget(self, action:#selector(onIntensityValueChanged(_:)), for: .valueChanged)
        
        return sldIntensity
    }()
    
    lazy var artCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(SDArtFilterCell.self, forCellWithReuseIdentifier: SDArtFilterCell.ArtFilterViewCell)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
}

extension ALArtFilterView {
    @objc private func doDiscard() {
        if let delegate = artFilterViewDelegate {
            delegate.doDiscard()
        }
        
        for art in artModels {
            art.selected = false
        }
        
        self.artCollectionView.reloadData()
        
        isApply = false
    }
    
    @objc private func doSelect(_ artModel: ALArtModel) {
        if let delegate = artFilterViewDelegate {
            if artModel.apiParams != nil {
                /*if artModel.isvip && !Utilities.isPurchased() {
                    delegate.doPremium(art: artModel)
                    isApply = false
                } else {*/
                delegate.doSelect(art: artModel)//doAnime(art: artModel)
                    isApply = true
                //}
            } else {
                delegate.doSelect(art: artModel)
                isApply = true
            }
            selectedArt = artModel
        }
    }
    
    @objc func onIntensityValueChanged(_ sender: UISlider!) {
        guard let art = selectedArt else { return }
        
        if let delegate = artFilterViewDelegate {
            self.intensityValue = sender.value / 100.0
            
            delegate.onIntensityValueChanged(art: art, value: CGFloat(self.intensityValue))
        }
    }
}

extension ALArtFilterView {
    private func initializeData() {
        if let arts = artFilterViewDataSource?.artModelsView() {
            artModels = arts
        }
        
        isApply = false
    }
    
    private func configureHierarchy() {
        addSubview(self.btnDiscard)
        addSubview(self.btnCompare)
        addSubview(self.sldIntensity)
        addSubview(self.artCollectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        btnDiscard.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(24)
        }
        
        btnCompare.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(24)
        }
        
        sldIntensity.snp.makeConstraints { (make) in
            make.centerY.equalTo(btnCompare.snp_centerY)
            make.left.equalTo(btnDiscard.snp_right).offset(20)
            make.right.equalTo(btnCompare.snp_left).offset(-20)
            make.height.equalTo(17)
        }
        
        artCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(70)
        }
    }
}

extension ALArtFilterView {
    func reset() {
        selectedArt = nil
        
        for art in artModels {
            art.selected = false
        }
        
        isApply = false
        sldIntensity.isHidden = true
        
        artCollectionView.reloadData()
    }
    
    func reloadCollectionView(){
        if selectedArt?.apiParams != nil {
            reset()
        } else {
            artCollectionView.reloadData()
        }
    }
    
    func selectAnime() {
        let animeKey = "anime"
        for index in 0..<artModels.count {
            if artModels[index].key.lowercased().contains(animeKey) {
                self.artCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .left)
                self.artCollectionView.delegate?.collectionView?(self.artCollectionView, didSelectItemAt: IndexPath(item: index, section: 0))
                
                return
            }
        }
    }
}

extension ALArtFilterView: UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.artModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SDArtFilterCell.ArtFilterViewCell, for: indexPath) as! SDArtFilterCell
        let art = self.artModels[indexPath.row]
        cell.artModel = art
        cell.isPremiumArt = false//art.isvip
        if let selected = self.selectedArt {
            if art.key == self.selectedArt?.key{
                cell.isArtSelected = true
            } else {
                cell.isArtSelected = false
            }
        }
       
        //if Utilities.isPurchased() {
          //  cell.isPremiumArt = false
        //}
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let artModel = self.artModels[indexPath.row]
        selectedArt = artModel
        artModel.selected = true
      
        self.intensityValue = 1
        self.sldIntensity.value = self.intensityValue * 100
        
        for art in self.artModels {
            if art == artModel {
                guard let selectedCell = collectionView.cellForItem(at: indexPath) else { return }

                let cell = selectedCell as! SDArtFilterCell
                cell.isArtSelected = true
            } else {
                art.selected = false
                
                let artIndexPath = IndexPath(row: self.artModels.firstIndex(of: art)!, section: 0)

                let normalCell = collectionView.cellForItem(at: artIndexPath)
                if let `normalCell` = normalCell {
                    let cell = normalCell as! SDArtFilterCell
                    cell.isArtSelected = false
                }
            }
        }
        
        self.doSelect(artModel)
        
        self.artCollectionView.reloadData()
        
    }
}

extension ALArtFilterView: HoldButtonDelegate {
    func didButtonHold(_ button: HoldButton) {
        guard let art = selectedArt else { return }
        
        if let delegate = artFilterViewDelegate {
            delegate.onHoldCompare(art: art)
        }
    }
    
    func didButtonUnhold(_ button: HoldButton) {
        guard let art = selectedArt else { return }
        
        if let delegate = artFilterViewDelegate {
            delegate.onUnholdCompare(art: art)
        }
    }
}

class SDArtFilterCell: UICollectionViewCell {
    public static let ArtFilterViewCell = "ArtFilterViewCell"
    
    var isArtSelected: Bool = false {
        didSet {
            imgSelected.isHidden = !isArtSelected
            vwSelectedBackground.isHidden = !isArtSelected
        }
    }
    
    var isPremiumArt: Bool = true {
        didSet{
            vipImageView.isHidden = !isPremiumArt
        }
    }
    
    var artModel: ALArtModel? {
        didSet {
            isArtSelected = artModel!.selected
                        
            guard let previewImage = artModel?.previewImage else { return }
            imgPreview.image = previewImage
            
            guard let vipImage = UIImage.init(named: "subscription_pro_icon")else{return}
            vipImageView.image = vipImage
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 7
        
        addSubview(self.imgPreview)
        addSubview(self.vwSelectedBackground)
        addSubview(self.imgSelected)
        
        self.imgPreview.addSubview(vipImageView)
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgPreview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        vipImageView.snp.makeConstraints{ (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(13)
            make.width.equalTo(28)
        }
        
        vwSelectedBackground.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        imgSelected.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(48)
            make.height.equalTo(20)
        }
    }
    private var vipImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    private var imgPreview: UIImageView = {
        let imgPreview = UIImageView()
        
        return imgPreview
    }()
    
    private var vwSelectedBackground: UIView = {
        let vwSelectedBackground = UIView()
        vwSelectedBackground.backgroundColor = UIColor.RGBA(r: 238, g: 96, b: 154, a: 0.8)
        vwSelectedBackground.isHidden = true
        vwSelectedBackground.layer.borderWidth = 2
        vwSelectedBackground.layer.borderColor = UIColor.RGB(r: 238, g: 96, b: 154).cgColor
        
        return vwSelectedBackground
    }()
    
    private var imgSelected: UIImageView = {
        let imgSelected = UIImageView()
        imgSelected.image = UIImage(named: "camera_selected_filter")
        imgSelected.isHidden = true
        
        return imgSelected
    }()
}

extension ALArtFilterView {
    func unfolderFilterCollectionWithAnimation() {
        guard let art = selectedArt else { return }
        guard let index = self.artModels.firstIndex(of: art) else { return }
        
        let pointOffset = CGPoint(x:(index * (60 + 5)).cgFloat - 31.cgFloat, y: self.artCollectionView.contentOffset.y)
        self.artCollectionView.setContentOffset(pointOffset, animated: true)
    }
}
