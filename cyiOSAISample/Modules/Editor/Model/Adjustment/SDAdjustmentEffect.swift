//
//  SDAdjustmentEffect.swift
//  cyiOSAISample
//
//  Created by admin on 2019/11/12.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import Foundation

public protocol SDIntensityFilterProtocol {
    var intensity:  CGFloat {get}
    func setIntensity(_ intensity: CGFloat)
    func renderFrame()
}

class SDRangeHandler: SDIntensityFilterProtocol {
    var minValue: CGFloat
    var maxValue: CGFloat
    var currentValue: CGFloat
    var defaultValue: CGFloat
    var bindingFilter: GPUImageFilter
    var intensityName: String
    
    var adjustedValue: CGFloat {
        return currentValue
    }
    
    var defaultIntensity: CGFloat {
        return (defaultValue - minValue) / (maxValue - minValue)
    }
    
    var intensity: CGFloat {
        get {
            return (currentValue - minValue) / (maxValue - minValue)
        }
        set {
            currentValue = minValue + newValue * (maxValue - minValue)
        }
    }
    
    func setIntensity(_ intensity: CGFloat) {
        self.intensity = intensity
    }
    
    func renderFrame() {
        
    }
    
    init(binding: GPUImageFilter, intensityName: String, minValue: CGFloat, maxValue: CGFloat, currentValue: CGFloat, defaultValue: CGFloat) {
        self.bindingFilter = binding
        self.intensityName = intensityName
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = currentValue
        self.defaultValue = defaultValue
    }
    
}


// MARK: -

class SDWhiteBanlanceRangHandler: SDRangeHandler {
    override var adjustedValue: CGFloat {
        return currentValue < 5000.0 ? 0.0004 * (currentValue - 5000.0) : 0.00006 * (currentValue - 5000.0)
    }
}

class SDHighlightRangeHandler: SDRangeHandler {
    override var intensity: CGFloat {
        get {
            let suIntensity = super.intensity
            return 1.0 - suIntensity
        }
        set {
            super.intensity = 1.0 - newValue
        }
    }
    
    override var defaultIntensity: CGFloat {
        return 0.0
    }
    
}

class SDVignetteRangeHandler: SDRangeHandler {
    override var adjustedValue: CGFloat {
        return currentValue < 5000.0 ?  0.0004 * (currentValue - 5000.0) : 0.00006 * (currentValue - 5000.0)
    }
    
    override var defaultIntensity: CGFloat {
        return 0.0
    }
    
}

class SDHorizontalRangeHandler: SDRangeHandler{
  override var adjustedValue: CGFloat {
        return currentValue < 5000.0 ?  0.0004 * (currentValue - 5000.0) : 0.00006 * (currentValue - 5000.0)
    }
    
    override var defaultIntensity: CGFloat {
        return 0.0
    }
}

class SDVerticalRangeHandler: SDRangeHandler{
  override var adjustedValue: CGFloat {
        return currentValue < 5000.0 ?  0.0004 * (currentValue - 5000.0) : 0.00006 * (currentValue - 5000.0)
    }
    
    override var defaultIntensity: CGFloat {
        return 0.0
    }
}

// MARK: - SDAdjustmentEffect

public class SDAdjustmentEffect {
    private var exposureAdjusment: GPUImageExposureFilter
    private var contrasAdjusment: GPUImageContrastFilter
    private var saturationAdjustment: GPUImageSaturationFilter
    private var sharpenAdjustment: GPUImageSharpenFilter
    private var highlightShadowAdjustment: GPUImageHighlightShadowFilter
    private var warmthAdjustment: GPUImageWhiteBalanceFilter
    private var vignetteAdjustment: GPUImageVignetteFilter
    private var mirrirAdjusment: GPUImageFilter
//    private var horizontalAdjustment : SDGPUHorizontalFilter
    
    private var exposureRange: SDRangeHandler
    private var contrasRange: SDRangeHandler
    private var saturationRange: SDRangeHandler
    private var sharpenRange: SDRangeHandler
    private var highlightRange: SDRangeHandler
    private var shadowRange: SDRangeHandler
    private var warmthRange: SDRangeHandler
    private var vignetteRange: SDRangeHandler
    private var mirrorRange: SDRangeHandler
    
    private var horizontalRange: SDRangeHandler
    private var verticalRange: SDRangeHandler
    
    private var exposureIntensityWrapper: IntensityEffectWrapper
    private var contrasIntensityWrapper: IntensityEffectWrapper
    private var saturationIntensityWrapper: IntensityEffectWrapper
    private var sharpeIntensityWrapper: IntensityEffectWrapper
    private var highlightIntensityWrapper: IntensityEffectWrapper
    private var shadowIntensityWrapper: IntensityEffectWrapper
    private var warmthIntensityWrapper: IntensityEffectWrapper
    private var vignetteIntensityWrapper: IntensityEffectWrapper
    private var mirrirIntensityWrapper: IntensityEffectWrapper
    
    var inputFilter: GPUImageFilter {
        return exposureAdjusment
    }
    
    var outputFilter: GPUImageFilter {
        return vignetteAdjustment
    }
    
    init() {
        exposureAdjusment = GPUImageExposureFilter()
        contrasAdjusment = GPUImageContrastFilter()
        saturationAdjustment = GPUImageSaturationFilter()
        sharpenAdjustment = GPUImageSharpenFilter()
        highlightShadowAdjustment = GPUImageHighlightShadowFilter()
        warmthAdjustment = GPUImageWhiteBalanceFilter()
        vignetteAdjustment = GPUImageVignetteFilter()
        mirrirAdjusment = GPUImageFilter()
        
        exposureAdjusment.addTarget(contrasAdjusment)
        contrasAdjusment.addTarget(saturationAdjustment)
        saturationAdjustment.addTarget(sharpenAdjustment)
        sharpenAdjustment.addTarget(highlightShadowAdjustment)
        highlightShadowAdjustment.addTarget(warmthAdjustment)
        warmthAdjustment.addTarget(vignetteAdjustment)
        
        
        exposureRange = SDRangeHandler(binding: exposureAdjusment, intensityName: "Exposure" , minValue: -0.35, maxValue: 0.35, currentValue: 0.0, defaultValue: 0.0)
        
        contrasRange = SDRangeHandler(binding: contrasAdjusment, intensityName: "Contrast", minValue: 0.5, maxValue: 1.5, currentValue: 1.0, defaultValue: 1.0)
        
        saturationRange = SDRangeHandler(binding: saturationAdjustment, intensityName: "Saturation", minValue: 0.0, maxValue: 2.0, currentValue: 1.0, defaultValue: 1.0)
        
        sharpenRange = SDRangeHandler(binding: sharpenAdjustment, intensityName: "Sharpen", minValue: -1.0, maxValue: 1.0, currentValue: 0.0, defaultValue: 0.0)
        
        highlightRange = SDRangeHandler(binding: highlightShadowAdjustment, intensityName: "Highlight", minValue: 0.0, maxValue: 2.0, currentValue: 2.0, defaultValue:2.0)
        
        shadowRange = SDRangeHandler(binding: highlightShadowAdjustment, intensityName: "Shadow", minValue: 0.0, maxValue: 2.0, currentValue: 0.0, defaultValue: 0.0)
        
        warmthRange = SDRangeHandler(binding: warmthAdjustment, intensityName: "Warmth", minValue: 4000, maxValue: 6000, currentValue: 5000, defaultValue: 5000)
        
        vignetteRange = SDRangeHandler(binding: vignetteAdjustment, intensityName: "Vignette", minValue: 0.7, maxValue: 0.0, currentValue: 0.7, defaultValue: 0.7)
        
        mirrorRange = SDRangeHandler(binding: mirrirAdjusment, intensityName: "Mirror", minValue: 0, maxValue: 0, currentValue: 0, defaultValue: 0)
        
        horizontalRange = SDRangeHandler(binding: vignetteAdjustment, intensityName: "Horizontal", minValue: -20.0, maxValue: 20.0, currentValue: 0.0, defaultValue: 0.0)
        
        verticalRange = SDRangeHandler(binding: vignetteAdjustment, intensityName: "Vertical", minValue: -20.0, maxValue: 20.0, currentValue: 0.0, defaultValue: 0.0)
        
        
        exposureIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.exposure.rawValue, targetFilter: exposureRange)
        
        contrasIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.contrast.rawValue, targetFilter: contrasRange)
        
        saturationIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.saturation.rawValue, targetFilter: saturationRange)
        
        sharpeIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.sharpen.rawValue, targetFilter: sharpenRange)
        
        highlightIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.hightlight.rawValue, targetFilter: highlightRange)
        
        shadowIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.shadow.rawValue, targetFilter: sharpenRange)
        
        warmthIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.warmth.rawValue, targetFilter: warmthRange)
        
        vignetteIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.vignette.rawValue, targetFilter: vignetteRange)
        
        mirrirIntensityWrapper = IntensityEffectWrapper(fundationId: SDFundation.mirror.rawValue, targetFilter: mirrorRange)
        
        updateIntensity(.vignette, value: 0.0)
    }
    
    func intensity(for function: SDFundation) -> CGFloat {
        switch function {
            case .exposure:
                return exposureRange.intensity
            case .contrast:
                return contrasRange.intensity
            case .saturation:
                return saturationRange.intensity
            case .sharpen:
                return sharpenRange.intensity
            case .hightlight:
                return highlightRange.intensity
            case .shadow:
                return shadowRange.intensity
            case .warmth:
                return warmthRange.intensity
            case .vignette:
                return vignetteRange.intensity
            case .horizontal:
                return sharpenRange.intensity
            case .mirror:
                return mirrorRange.currentValue
            
            default:
                return 1.0
        }
    }
    
    func userIntensity(for fundation: SDFundation, slider value: CGFloat) -> Int {
        switch fundation {
            case .hightlight, .shadow, .vignette:
                return Int(value * 100)
            case .contrast, .saturation, .warmth,.sharpen, .exposure:
                return Int((value - 0.5) * 100)
            case .vertical, .horizontal:
                return Int((value - 0.5) * 90)
            default:
                return 100
        }
    }
    
    func updateIntensity(_ fundation: SDFundation, value: CGFloat, requestRender: Bool = true) {
        switch fundation {
            case .exposure:
                exposureRange.intensity = value
                exposureAdjusment.exposure = exposureRange.currentValue
            break
            
            case .contrast:
                contrasRange.intensity = value
                contrasAdjusment.contrast = contrasRange.currentValue
            break
            
            case .saturation:
                saturationRange.intensity = value
                saturationAdjustment.saturation = saturationRange.currentValue
            break
            
            case .sharpen:
                sharpenRange.intensity = value
                sharpenAdjustment.sharpness = sharpenRange.currentValue
            break
            
            case .hightlight:
                 highlightRange.intensity = value
                 highlightShadowAdjustment.highlights = highlightRange.currentValue
            break
            
            case .shadow:
                 shadowRange.intensity = value
                 highlightShadowAdjustment.shadows = shadowRange.currentValue
            break
            
            case .warmth:
                 warmthRange.intensity = value
                 warmthAdjustment.temperature = warmthRange.currentValue
            break
            
            case .vignette:
                vignetteRange.intensity = value
                vignetteAdjustment.vignetteStart = vignetteRange.currentValue
                
            break
            case .horizontal:
                horizontalRange.intensity = value
                
                break
            case .vertical :
                verticalRange.intensity = value
                break
            
            case .mirror: //Mirror used times
                mirrorRange.currentValue += value
                break
            default:
            break
            
        }
    }
    
    func defaultIntensity(for function: SDFundation) -> CGFloat {
        switch function {
        case .exposure:
            return exposureRange.defaultIntensity
        case .contrast:
            return contrasRange.defaultIntensity
        case .saturation:
            return saturationRange.defaultIntensity
        case .sharpen:
            return sharpenRange.defaultIntensity
        case .hightlight:
            return highlightRange.defaultIntensity
        case .shadow:
            return shadowRange.defaultIntensity
        case .warmth:
            return warmthRange.defaultIntensity
        case .vignette:
            return vignetteRange.defaultIntensity
        case .horizontal:
            return horizontalRange.defaultIntensity
        case .vertical:
            return verticalRange.defaultIntensity
        case .mirror:
            return mirrorRange.currentValue
        default:
            return 1
        }
    }
    
    func rangeHelperFor(_ function: SDFundation) -> SDRangeHandler {
        switch function {
        case .exposure:
            return exposureRange
        case .contrast:
            return contrasRange
        case .saturation:
            return saturationRange
        case .sharpen:
            return sharpenRange
        case .hightlight:
            return highlightRange
        case .shadow:
            return shadowRange
        case .warmth:
            return warmthRange
        case .vignette:
            return vignetteRange
        case .horizontal:
            return horizontalRange
        case .vertical:
            return verticalRange
        case .mirror:
            return mirrorRange
        default:
            return exposureRange
        }
    }
    
    func intensityWrapperFor(_ fundation: SDFundation) -> IntensityEffectWrapper {
        switch fundation {
            case .exposure:
                return exposureIntensityWrapper
            case .contrast:
                return contrasIntensityWrapper
            case .saturation:
                return saturationIntensityWrapper
            case .sharpen:
                return sharpeIntensityWrapper
            case .hightlight:
                return highlightIntensityWrapper
            case .shadow:
                return shadowIntensityWrapper
            case .warmth:
                return warmthIntensityWrapper
            case .vignette:
                return vignetteIntensityWrapper
            case .mirror:
                return mirrirIntensityWrapper
            
            default:
            return exposureIntensityWrapper
        }
    }
    
    func recordIntensity(for fundation: SDFundation, fromValue: CGFloat, toValue: CGFloat) {
        intensityWrapperFor(fundation).appendItem(fromValue: fromValue, toValue: toValue)
    }
    
}
