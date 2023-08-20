//
//  SDEditOperationsPanel.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/12.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

public protocol ALEditOperationsPanelDelegate: NSObjectProtocol {
    func didUndoClick()
    func didRedoClick()
    func didIntensityChanged(_ sender: UISlider)
    func didIntensityChangeEnd(_ sender: UISlider)
    func didShowOriginalBegan()
    func didShowOriginalEnd()
    func editOperationsPanel(_ panel: ALEditOperationsPanel, touchesBegan: Set<UITouch>, with event: UIEvent?)
    func editOperationsPanel(_ panel: ALEditOperationsPanel, touchesEnded: Set<UITouch>, with event: UIEvent?)
}

extension ALEditOperationsPanelDelegate {
    public func didUndoClick() { }
    public func didRedoClick() { }
    public func didIntensityChanged(_ sender: UISlider) { }
    public func didIntensityChangeEnd(_ sender: UISlider) { }
    public func didShowOriginalBegan() { }
    public func didShowOriginalEnd() { }
    public func editOperationsPanel(_ panel: ALEditOperationsPanel, touchesBegan: Set<UITouch>, with event: UIEvent?) { }
    public func editOperationsPanel(_ panel: ALEditOperationsPanel, touchesEnded: Set<UITouch>, with event: UIEvent?) { }
}

public class ALEditOperationsPanel: UIView {
    
    public weak var delegate: ALEditOperationsPanelDelegate? = nil
        
    private var undoButton: UIButton
    private var redoButton: UIButton
    private var intensitySlider: SDCustomSlider
    private var showOriginalButton: HoldButton
    
    public var isUndoButtonHidden: Bool = false {
        didSet {
            undoButton.isHidden = isUndoButtonHidden
        }
    }
    public var isRedoButtonHidden: Bool = false {
        didSet {
            redoButton.isHidden = isRedoButtonHidden
        }
    }
    public var isIntensitySliderHidden: Bool {
        set {
            intensitySlider.isHidden = newValue
        }
        get {
            return intensitySlider.isHidden
        }
    }
    
    public var isShowOriginalButtonHidden: Bool = false {
        didSet {
            showOriginalButton.isHidden = isShowOriginalButtonHidden
        }
    }
    
    public var isShowSilderValueHidden: Bool = true {
        didSet {
            intensitySlider.showPresenter = isShowSilderValueHidden
        }
    }
    
    public var isUndoButtonEnable: Bool = false {
        didSet {
            undoButton.isEnabled = isUndoButtonEnable
        }
    }
    public var isRedoButtonEnable: Bool = false {
        didSet {
            redoButton.isEnabled = isRedoButtonEnable
        }
    }
    
    public var intensitySliderValueString: String? {
        didSet {
            intensitySlider.valueDirect = intensitySliderValueString
        }
    }
    
    public var intensitySliderValue: Float = 1.0 {
        didSet {
            intensitySlider.value = intensitySliderValue
        }
    }
    
    public var intensitySliderValueMax: Float = 1.0 {
        didSet {
            intensitySlider.maximumValue = intensitySliderValueMax
        }
    }
    
    public var intensitySliderValueMin: Float = 0.0 {
        didSet {
            intensitySlider.minimumValue = intensitySliderValueMin
        }
    }
    
    var sliderValue : Float {
        return intensitySlider.value
    }
    
    public override init(frame: CGRect) {
        undoButton = UIButton(type: .custom)
        redoButton = UIButton(type: .custom)
        intensitySlider = SDCustomSlider()
        showOriginalButton = HoldButton()
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        undoButton = UIButton(type: .custom)
        redoButton = UIButton(type: .custom)
        intensitySlider = SDCustomSlider()
        showOriginalButton = HoldButton()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        undoButton.isHidden = true
        undoButton.setImage(UIImage(named: "editor_undo"), for: .normal)
        undoButton.addTarget(self, action: #selector(didUndoButtonClick), for: .touchUpInside)
        redoButton.isHidden = true
        redoButton.setImage(UIImage(named: "editor_redo"), for: .normal)
        redoButton.addTarget(self, action: #selector(didRedoButtonClick), for: .touchUpInside)
        showOriginalButton.image = UIImage(named: "editor_compare")
        showOriginalButton.delegate = self
        
        undoButton.isEnabled = false
        redoButton.isEnabled = false

        intensitySlider = SDCustomSlider()
        intensitySlider.minimumValue = self.intensitySliderValueMin
        intensitySlider.maximumValue = self.intensitySliderValueMax
        intensitySlider.minimumTrackTintColor = UIColor.RGB(r: 249, g: 75, b: 189)
        intensitySlider.maximumTrackTintColor = UIColor.RGB(r: 255, g: 255, b: 255)
        intensitySlider.addTarget(self, action: #selector(didSliderValueChanged(_:)), for: .valueChanged)
        intensitySlider.addTarget(self, action: #selector(didSliderTouchEnd(_:)), for: .touchCancel)
        intensitySlider.addTarget(self, action: #selector(didSliderTouchEnd(_:)), for: .touchUpInside)
        intensitySlider.addTarget(self, action: #selector(didSliderTouchEnd(_:)), for: .touchUpOutside)
        
        addSubview(undoButton)
        addSubview(redoButton)
        addSubview(showOriginalButton)
        addSubview(intensitySlider)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        undoButton.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(5)
            maker.top.equalToSuperview().offset(4)
            maker.width.height.equalTo(24)
        }
        
        redoButton.snp.makeConstraints { maker in
            maker.right.equalTo(intensitySlider.snp_left).offset(-20)
            maker.centerY.equalTo(undoButton)
            maker.width.height.equalTo(24)
        }
        
        intensitySlider.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(88)
            maker.right.equalToSuperview().offset(-88)
            maker.height.equalTo(17)
            maker.centerY.equalTo(undoButton)
        }
        
        showOriginalButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-20)
            maker.centerY.equalTo(undoButton)
            maker.width.height.equalTo(24)
        }
    }
    
    public func intensitySliderTrackPositionFor(_ intensity: Float) -> CGPoint {
        let minX = intensitySlider.frame.minX + 10.0
        let maxX = intensitySlider.frame.maxX - 10.0
        return CGPoint(x: minX + (maxX - minX) * CGFloat(intensity), y: frame.origin.y)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.editOperationsPanel(self, touchesBegan: touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.editOperationsPanel(self, touchesEnded: touches, with: event)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hittedView = super.hitTest(point, with: event)
        if hittedView == self {
            return nil
        }
        return hittedView
    }
    
    @objc func didUndoButtonClick() {
        delegate?.didUndoClick()
    }
    
    @objc func didRedoButtonClick() {
        delegate?.didRedoClick()
    }
    
    @objc func didShowOriginalButtonTouchInside() {
        delegate?.didShowOriginalBegan()
    }
    
    @objc func didShowOrignalButtonTouchUp() {
        delegate?.didShowOriginalEnd()
    }
    
    @objc private func didSliderValueChanged(_ sender: UISlider) {
        delegate?.didIntensityChanged(sender)
    }
    
    @objc private func didSliderTouchEnd(_ sender: UISlider) {
        delegate?.didIntensityChangeEnd(sender)
    }
}

extension ALEditOperationsPanel: HoldButtonDelegate {
    func didButtonHold(_ button: HoldButton) {
        didShowOriginalButtonTouchInside()
    }
    
    func didButtonUnhold(_ button: HoldButton) {
        didShowOrignalButtonTouchUp()
    }
}


extension ALEditOperationsPanel{
    func remakeEditViewConstraint(){
        intensitySlider.snp.remakeConstraints { maker in
            maker.left.equalToSuperview().offset(64)
            maker.right.equalTo(showOriginalButton.snp_left).offset(-20)
            maker.height.equalTo(17)
            maker.centerY.equalTo(undoButton)
        }
    }
}
