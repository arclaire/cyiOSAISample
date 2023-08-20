//
//  SDCropRatioView.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/13.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

fileprivate let lineSize = 42.cgFloat
fileprivate let lineH = 8.cgFloat

enum LineDirection {
    case horizontal, vertical
}

class LineView: UIView {
    public var lineColor: UIColor = .white
    public var lineWidth: CGFloat = lineSize
    public var lineHeight: CGFloat = lineH
    public var lineDirection:LineDirection = .vertical
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(lineColor.cgColor)
        context?.setLineWidth(lineH)
        context?.setLineCap(CGLineCap.round)
        context?.beginPath()
        var point1 = CGPoint(x: 0 + lineH * 0.5, y: rect.size.height * 0.5)
        var point2 = CGPoint(x: rect.size.width - lineH * 0.5, y: rect.size.height * 0.5)
    
        if lineDirection == .vertical {
            point1 = CGPoint(x: rect.size.width * 0.5, y: 0 + lineH * 0.5)
            point2 = CGPoint(x: rect.size.width * 0.5, y: rect.size.height - lineH * 0.5)
        }
        
        context?.addLines(between: [point1, point2])
        context?.strokePath()
       
    }
}


class SDCropRatioView: UIView {
    private let angleImageViewSize = 60.cgFloat
    private let animateTime: TimeInterval = 0.5
    
    public var ratioInfo: SDCropEffectModel = .free {
        didSet {
            self.setupVisibleArea()
        }
    }
    private var changableVisitionAreaLayer: SCChangableVisitionAreaLayer!
    private var topLeftAngleView: UIImageView!
    private var topRightAngleView: UIImageView!
    private var bottomLeftAngleView: UIImageView!
    private var bottomRightAngleView: UIImageView!
    
    private var topLineView: LineView!
    private var bottomLineView: LineView!
    private var leftLineView: LineView!
    private var rightLineView: LineView!
    
    var cropRect: CGRect? {
        get {
            return self.changableVisitionAreaLayer.cropingRect
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        if (changableVisitionAreaLayer != nil) {
            changableVisitionAreaLayer.setNeedsDisplay()
        }
    }
    
    private func setupVisibleArea() {
        let lineViewHidden = ratioInfo == .free ? false : true
        self.topLineView.isHidden = lineViewHidden
        self.bottomLineView.isHidden = lineViewHidden
        self.leftLineView.isHidden = lineViewHidden
        self.rightLineView.isHidden = lineViewHidden
        self.topLeftAngleView.isHidden = false
        self.topRightAngleView.isHidden = false
        self.bottomLeftAngleView.isHidden = false
        self.bottomRightAngleView.isHidden = false
        
        let cropRect = getCropRect()
        
        setupCropRect(cropRect: cropRect, animated: false)
    }
    
    private func getCropRect() -> CGRect {
        var rect = self.bounds
        
        switch ratioInfo {
        case .free:
            return rect
        case .ratio1_1, .ratio4_5, .ratio3_4, .ratio4_3, .ratio16_9,.ratio9_16,.ratio2_3,.ratio3_2:
            let H = rect.size.width * ratioInfo.toRatio()
            if rect.size.height > H {
                rect.size.height = H
            } else {
                rect.size.width = rect.size.height / ratioInfo.toRatio()
            }
            
            rect.origin.x = (self.bounds.size.width - rect.size.width) * 0.5
            rect.origin.y = (self.bounds.size.height - rect.size.height) * 0.5
            return rect
        }
    }
    
    private func setupCropRect(cropRect: CGRect, animated: Bool) {
        if animated {
            let animation = CABasicAnimation.init(keyPath: "cropRect")
            animation.duration = animateTime
            animation.fromValue = self.cropRect
            animation.toValue = cropRect
            changableVisitionAreaLayer.add(animation, forKey: nil)
            changableVisitionAreaLayer.cropingRect = cropRect
            self.setNeedsDisplay()
            
            UIView.animate(withDuration: animateTime) {
                self.setupAngleViewConstraints(cropRect: cropRect)
            }
        } else {
            self.setupAngleViewConstraints(cropRect: cropRect)
            changableVisitionAreaLayer.cropingRect = cropRect
            self.setNeedsDisplay()
        }
    }
    
    private func initView() {
        changableVisitionAreaLayer = SCChangableVisitionAreaLayer.init()
        changableVisitionAreaLayer.frame = self.bounds
        layer.addSublayer(changableVisitionAreaLayer)
        changableVisitionAreaLayer.setNeedsDisplay()
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(translatePan(_:)))
        self.addGestureRecognizer(panGesture)
        
        self.topLeftAngleView = createAngleView(angleDirection: .up)
        self.topRightAngleView = createAngleView(angleDirection: .right)
        self.bottomLeftAngleView = createAngleView(angleDirection: .left)
        self.bottomRightAngleView = createAngleView(angleDirection: .down)
        
        self.topLineView = createLineView(direction: .horizontal)
        self.bottomLineView = createLineView(direction: .horizontal)
        self.leftLineView = createLineView(direction: .vertical)
        self.rightLineView = createLineView(direction: .vertical)
        
        addSubview(self.topLeftAngleView)
        addSubview(self.topRightAngleView)
        addSubview(self.bottomLeftAngleView)
        addSubview(self.bottomRightAngleView)
        
        addSubview(self.topLineView)
        addSubview(self.bottomLineView)
        addSubview(self.leftLineView)
        addSubview(self.rightLineView)
        
        self.topLeftAngleView.isHidden = true
        self.topRightAngleView.isHidden = true
        self.bottomLeftAngleView.isHidden = true
        self.bottomRightAngleView.isHidden = true
        
        self.topLineView.isHidden = true
        self.bottomLineView.isHidden = true
        self.leftLineView.isHidden = true
        self.rightLineView.isHidden = true
        
        setupAngleViewConstraints(cropRect: self.cropRect)
    }
    
    func setupAngleViewConstraints(cropRect: CGRect?) {
        guard let cropRect = cropRect else {
            return
        }
        
        self.topLeftAngleView.center = CGPoint(x: cropRect.minX, y: cropRect.minY)
        self.topRightAngleView.center = CGPoint(x: cropRect.maxX, y: cropRect.minY)
        self.bottomLeftAngleView.center = CGPoint(x: cropRect.minX, y: cropRect.maxY)
        self.bottomRightAngleView.center = CGPoint(x: cropRect.maxX, y: cropRect.maxY)
        self.topLineView.center = CGPoint(x: cropRect.minX + cropRect.width * 0.5, y: cropRect.minY)
        self.bottomLineView.center = CGPoint(x: cropRect.minX + cropRect.width * 0.5, y: cropRect.maxY)
        self.leftLineView.center = CGPoint(x: cropRect.minX, y: cropRect.minY + cropRect.height * 0.5)
        self.rightLineView.center = CGPoint(x: cropRect.maxX, y: cropRect.minY + cropRect.height * 0.5)
    }
    
    private func createLineView(direction: LineDirection) -> LineView {
        let lineView = LineView()
        lineView.frame = CGRect(x: 0, y: 0, width: lineSize, height: lineSize)
        lineView.backgroundColor = .clear
        lineView.lineDirection = direction
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(changeSizePan(_:)))
        lineView.addGestureRecognizer(panGesture)
        
        return lineView;
    }
    
    private func createAngleView(angleDirection: UIImage.Orientation) -> UIImageView {
        let angleView = UIImageView.init()
        let image = UIImage(named: "editor_crop_scale")
        
        let angleImage = UIImage.init(cgImage: image!.cgImage!, scale: image!.scale, orientation: angleDirection)
        angleView.image = angleImage
        angleView.contentMode = .center
        angleView.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(changeSizePan(_:)))
        angleView.addGestureRecognizer(panGesture)
        angleView.frame = CGRect(x: 0, y: 0, width: angleImageViewSize, height: angleImageViewSize)
        return angleView
    }
    
    var initialRect: CGRect = .zero
    var dragging: Bool = false
    
    @objc private func translatePan(_ pan:UIPanGestureRecognizer) {
        guard let cropRect = self.changableVisitionAreaLayer.cropingRect else {
            return
        }
        if pan.state == .began {
            let point = pan.location(in: self)
            dragging = cropRect.contains(point)
            initialRect = cropRect
        }
        else if(dragging) {
            let point = pan.translation(in: self)
            let left = min(max(initialRect.origin.x + point.x, 0), self.frame.size.width - initialRect.size.width)
            let top = min(max(initialRect.origin.y + point.y, 0), self.frame.size.height - initialRect.size.height)
            var rct = cropRect
            rct.origin.x = left
            rct.origin.y = top
            setupCropRect(cropRect: rct, animated: false)
        }
    }
    
    var initialPoint: CGPoint!
    
     var beginRct: CGRect = CGRect.zero
    
    @objc private func changeSizePan(_ pan:UIPanGestureRecognizer) {
        if pan.state == .began {
            beginRct = self.cropRect!
        }
        
        var point = pan.location(in: self)
        let dp = pan.translation(in: self)
        var rct = self.changableVisitionAreaLayer.cropingRect!
        let w = self.frame.size.width
        let h = self.frame.size.height
        var minX = 0.cgFloat
        var minY = 0.cgFloat
        var maxX = w
        var maxY = h
        
        let ratio = (pan.view == self.topRightAngleView || pan.view == self.bottomLeftAngleView) ? -self.ratioInfo.toRatio() : self.ratioInfo.toRatio()
        
        switch pan.view {
        case self.topLeftAngleView:
            maxX = max(rct.origin.x + rct.size.width - 0.2 * w, 0.2 * w)
            maxY = max(rct.origin.y + rct.size.height - 0.2 * h, 0.2 * h)
            
            if (ratio == 0) {
                point.x = max(minX, min(point.x, maxX))
                point.y = max(minY, min(point.y, maxY))
            } else {
                let y0 = rct.origin.y - ratio * rct.origin.x
                let x0 = -y0 / ratio
                minX = max(x0, 0)
                minY = max(y0, 0)
                point.x = max(minX, min(point.x, maxX))
                point.y = max(minY, min(point.y, maxY))
                
                if(-dp.x * ratio + dp.y > 0) {
                    point.x = (point.y - y0) / ratio
                }
                else {
                    point.y = point.x * ratio + y0
                }
            }
            
            rct.size.width = rct.size.width - (point.x - rct.origin.x)
            rct.size.height = rct.size.height - (point.y - rct.origin.y)
            rct.origin.x = point.x
            rct.origin.y = point.y
        case self.topRightAngleView:
            minX = max(rct.origin.x + 0.2 * w, 0.2 * w)
            maxY = max(rct.origin.y + rct.size.height - 0.2 * h, 0.2 * h)
            
            if (ratio == 0) {
                point.x = max(minX, min(point.x, maxX))
                point.y = max(minY, min(point.y, maxY))
            } else {
                let y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width)
                let yw = ratio * w + y0
                let x0 = -y0 / ratio
                maxX = min(x0, w)
                minY = max(yw, 0)
                point.x = max(minX, min(point.x, maxX))
                point.y = max(minY, min(point.y, maxY))
                
                if(-dp.x * ratio + dp.y > 0) {
                    point.x = (point.y - y0) / ratio
                }
                else {
                    point.y = point.x * ratio + y0
                }
            }
            
            rct.size.width = point.x - rct.origin.x
            rct.size.height = rct.size.height - (point.y - rct.origin.y)
            rct.origin.y = point.y
        case self.bottomLeftAngleView:
            maxX = max((rct.origin.x + rct.size.width)  - 0.2 * w, 0.2 * w);
            minY = max(rct.origin.y + 0.2 * h, 0.2 * h);
            
            if (ratio != 0) {
               let y0 = (rct.origin.y + rct.size.height) - ratio * rct.origin.x ;
                let xh = (h - y0) / ratio;
                minX = max(xh, 0);
                maxY = min(y0, h);
                
                point.x = max(minX, min(point.x, maxX));
                point.y = max(minY, min(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = max(minX, min(point.x, maxX));
                point.y = max(minY, min(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
        case self.bottomRightAngleView:
            minX = max(rct.origin.x + 0.2 * w, 0.2 * w);
            minY = max(rct.origin.y + 0.2 * h, 0.2 * h);
            
            if (ratio == 0) {
                point.x = max(minX, min(point.x, maxX));
                point.y = max(minY, min(point.y, maxY));
            } else {
                let y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                let yw = ratio * w + y0;
                let xh = (h - y0) / ratio;
                maxX = min(xh, w);
                maxY = min(yw, h);
                
                point.x = max(minX, min(point.x, maxX));
                point.y = max(minY, min(point.y, maxY));
                
                if (-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
        case self.topLineView:
            if point.y < 0 {
                point.y = 0
            }
            
            if (beginRct.maxY - point.y) < h * 0.2 {
                point.y = beginRct.maxY - h * 0.2
            }
           
            rct.origin.y = point.y
            rct.size.height = beginRct.maxY - point.y
          
        case self.bottomLineView:
            if point.y > h {
                point.y = h
            }
            
            if point.y - beginRct.minY < h * 0.2 {
                point.y = beginRct.minY + h * 0.2
            }
           
            rct.size.height =  point.y - beginRct.minY
        case self.leftLineView:
            if point.x < 0 {
                point.x = 0
            }
            
            if beginRct.maxX - point.x < h * 0.2 {
                point.x = beginRct.maxX - h * 0.2
            }
            
            rct.origin.x = point.x
            rct.size.width =   beginRct.maxX - point.x
        case self.rightLineView:
            if point.x > w {
                point.x = w
            }
            
            if point.x - beginRct.minX < h * 0.2 {
                point.x = beginRct.minX + h * 0.2
            }
            
            rct.size.width =   point.x - beginRct.minX
        default:
            break
        }
        
        self.changableVisitionAreaLayer.cropingRect = rct
        self.changableVisitionAreaLayer.setNeedsDisplay()
        
        self.setupCropRect(cropRect: rct, animated: false)
    }
}

class SCChangableVisitionAreaLayer: CALayer {
    public var cropingRect: CGRect? {
        didSet {
        }
    }
    public var bgColor: UIColor! = UIColor(hex: "000000", alpha: 0.66)//00000066
    public var changableAreaBorderColor:UIColor! = .white
    public var changableAreaGridColor: UIColor! = UIColor(hex: "FFFFFF", alpha: 0.9)
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "cropingRect" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
        
        if layer is SCChangableVisitionAreaLayer {
            self.cropingRect = (layer as! SCChangableVisitionAreaLayer).cropingRect
            self.bgColor = (layer as! SCChangableVisitionAreaLayer).bgColor
            self.changableAreaBorderColor = (layer as! SCChangableVisitionAreaLayer).changableAreaBorderColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        guard let cropingRect = cropingRect else {
            return
        }
        let rct = self.bounds
        ctx.setFillColor(self.bgColor.cgColor)
        ctx.fill(rct)
        ctx.clear(cropingRect)
        ctx.setStrokeColor(self.changableAreaBorderColor.cgColor)
        ctx.beginPath()
        let lineW = 2.cgFloat
        ctx.setLineWidth(lineW)
        ctx.addRect(cropingRect)
        ctx.strokePath()
        
        ctx.beginPath()
        let lineW2 = 1.cgFloat
        ctx.setLineWidth(lineW2)
        ctx.setStrokeColor(self.changableAreaGridColor.cgColor)
        var dx = 0.cgFloat
        for _ in 0...1 {
            dx += cropingRect.size.width/3.0
            let point1 = CGPoint(x: cropingRect.origin.x + dx, y: cropingRect.origin.y)
            let point2 = CGPoint(x: cropingRect.origin.x + dx, y: cropingRect.origin.y + cropingRect.size.height)
            ctx.addLines(between: [point1, point2])
        }
        
        var dy = 0.cgFloat
        for _ in 0...1 {
            dy += cropingRect.size.height/3.0
            let point1 = CGPoint(x: cropingRect.origin.x, y: cropingRect.origin.y + dy)
            let point2 = CGPoint(x: cropingRect.origin.x + cropingRect.size.width, y: cropingRect.origin.y + dy)
            ctx.addLines(between: [point1, point2])
        }
        
        ctx.strokePath()
    }
}
