//
//  SDGPUImageHighPassSkinSmoothingFilter.m
//  cyiOSAISample
//
//  Created by leni santi on 18/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import "SDGPUImageHighPassSkinSmoothingFilter.h"
#import "SDGPUImageStillImageHighPassFilter.h"
#import "SDGPUImageDefines.h"
#import "GPUImageDissolveBlendFilter.h"
#import "GPUImageSharpenFilter.h"
#import "GPUImageToneCurveFilter.h"
#import "GPUImageExposureFilter.h"
#import "GPUImageThreeInputFilter.h"

NSString * const SDCIHighPassSkinSmoothingMaskBoostFilterFragmentShaderString =
SHADER_STRING
(
 SD_GLSL_FLOAT_PRECISION_LOW
 varying SD_GLSL_PRECISION_HIGH vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 void main() {
     vec4 color = texture2D(inputImageTexture,textureCoordinate);
     
     float hardLightColor = color.b;
     for (int i = 0; i < 3; ++i)
     {
         if (hardLightColor < 0.5) {
             hardLightColor = hardLightColor  * hardLightColor * 2.;
         } else {
             hardLightColor = 1. - (1. - hardLightColor) * (1. - hardLightColor) * 2.;
         }
     }
     
     float k = 255.0 / (164.0 - 75.0);
     hardLightColor = (hardLightColor - 75.0 / 255.0) * k;
     
     gl_FragColor = vec4(vec3(hardLightColor),color.a);
 }
);

NSString * const SDGPUImageGreenAndBlueChannelOverlayFragmentShaderString =
SHADER_STRING
(
 SD_GLSL_FLOAT_PRECISION_LOW
 varying SD_GLSL_PRECISION_HIGH vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 void main() {
     vec4 image = texture2D(inputImageTexture, textureCoordinate);
     vec4 base = vec4(image.g,image.g,image.g,1.0);
     vec4 overlay = vec4(image.b,image.b,image.b,1.0);
     float ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
     gl_FragColor = vec4(ba,ba,ba,image.a);
 }
);

@interface SDCIHighPassSkinSmoothingMaskGenerator : GPUImageFilterGroup

@property (nonatomic) CGFloat highPassRadiusInPixels;

@property (nonatomic,weak) SDGPUImageStillImageHighPassFilter *highPassFilter;

@end

@implementation SDCIHighPassSkinSmoothingMaskGenerator

- (instancetype)init {
    if (self = [super init]) {
        GPUImageFilter *channelOverlayFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:SDGPUImageGreenAndBlueChannelOverlayFragmentShaderString];
        [self addFilter:channelOverlayFilter];
        
        SDGPUImageStillImageHighPassFilter *highpassFilter = [[SDGPUImageStillImageHighPassFilter alloc] init];
        [self addFilter:highpassFilter];
        self.highPassFilter = highpassFilter;
        
        GPUImageFilter *maskBoostFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:SDCIHighPassSkinSmoothingMaskBoostFilterFragmentShaderString];
        [self addFilter:maskBoostFilter];
        
        [channelOverlayFilter addTarget:highpassFilter];
        [highpassFilter addTarget:maskBoostFilter];
        
        self.initialFilters = @[channelOverlayFilter];
        self.terminalFilter = maskBoostFilter;
    }
    return self;
}

- (void)setHighPassRadiusInPixels:(CGFloat)highPassRadiusInPixels {
    self.highPassFilter.radiusInPixels = highPassRadiusInPixels;
}

- (CGFloat)highPassRadiusInPixels {
    return self.highPassFilter.radiusInPixels;
}

@end

@interface SDGPUImageHighPassSkinSmoothingRadius ()

@property (nonatomic) CGFloat value;
@property (nonatomic) SDGPUImageHighPassSkinSmoothingRadiusUnit unit;

@end

@implementation SDGPUImageHighPassSkinSmoothingRadius

+ (instancetype)radiusInPixels:(CGFloat)pixels {
    SDGPUImageHighPassSkinSmoothingRadius *radius = [SDGPUImageHighPassSkinSmoothingRadius new];
    radius.unit = SDGPUImageHighPassSkinSmoothingRadiusUnitPixel;
    radius.value = pixels;
    return radius;
}

+ (instancetype)radiusAsFractionOfImageWidth:(CGFloat)fraction {
    SDGPUImageHighPassSkinSmoothingRadius *radius = [SDGPUImageHighPassSkinSmoothingRadius new];
    radius.unit = SDGPUImageHighPassSkinSmoothingRadiusUnitFractionOfImageWidth;
    radius.value = fraction;
    return radius;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.value = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(value))] floatValue];
        self.unit = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(unit))] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.value) forKey:NSStringFromSelector(@selector(value))];
    [aCoder encodeObject:@(self.unit) forKey:NSStringFromSelector(@selector(unit))];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

NSString * const SDGPUImageHighpassSkinSmoothingCompositingFilterFragmentShaderString =
SHADER_STRING
(
 SD_GLSL_FLOAT_PRECISION_LOW
 varying SD_GLSL_PRECISION_HIGH vec2 textureCoordinate;
 varying SD_GLSL_PRECISION_HIGH vec2 textureCoordinate2;
 varying SD_GLSL_PRECISION_HIGH vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 void main() {
     vec4 image = texture2D(inputImageTexture, textureCoordinate);
     vec4 toneCurvedImage = texture2D(inputImageTexture2, textureCoordinate);
     vec4 mask = texture2D(inputImageTexture3, textureCoordinate);
     gl_FragColor = vec4(mix(image.rgb,toneCurvedImage.rgb,1.0 - mask.b),1.0);
 }
);

@interface SDGPUImageHighPassSkinSmoothingFilter ()

@property (nonatomic,weak) SDCIHighPassSkinSmoothingMaskGenerator *maskGenerator;

@property (nonatomic,weak) GPUImageDissolveBlendFilter *dissolveFilter;

@property (nonatomic,weak) GPUImageSharpenFilter *sharpenFilter;

@property (nonatomic,weak) GPUImageToneCurveFilter *skinToneCurveFilter;

@property (nonatomic) CGSize currentInputSize;

@end

@implementation SDGPUImageHighPassSkinSmoothingFilter

- (instancetype)init {
    if (self = [super init]) {
        GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
        exposureFilter.exposure = -1.0;
        [self addFilter:exposureFilter];
        
        SDCIHighPassSkinSmoothingMaskGenerator *maskGenerator = [[SDCIHighPassSkinSmoothingMaskGenerator alloc] init];
        [self addFilter:maskGenerator];
        self.maskGenerator = maskGenerator;
        [exposureFilter addTarget:maskGenerator];
        
        GPUImageToneCurveFilter *skinToneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [self addFilter:skinToneCurveFilter];
        self.skinToneCurveFilter = skinToneCurveFilter;
        
        GPUImageDissolveBlendFilter *dissolveFilter = [[GPUImageDissolveBlendFilter alloc] init];
        [self addFilter:dissolveFilter];
        self.dissolveFilter = dissolveFilter;
        
        [skinToneCurveFilter addTarget:dissolveFilter atTextureLocation:1];
        
        GPUImageThreeInputFilter *composeFilter = [[GPUImageThreeInputFilter alloc] initWithFragmentShaderFromString:SDGPUImageHighpassSkinSmoothingCompositingFilterFragmentShaderString];
        [self addFilter:composeFilter];
        
        [maskGenerator addTarget:composeFilter atTextureLocation:2];
        [self.dissolveFilter addTarget:composeFilter atTextureLocation:1];
        
        GPUImageSharpenFilter *sharpen = [[GPUImageSharpenFilter alloc] init];
        [self addFilter:sharpen];
        [composeFilter addTarget:sharpen];
        self.sharpenFilter = sharpen;
        
        self.initialFilters = @[exposureFilter,skinToneCurveFilter,dissolveFilter,composeFilter];
        self.terminalFilter = sharpen;
        
        //set defaults
        self.amount = 0.75;
        self.radius = [SDGPUImageHighPassSkinSmoothingRadius radiusAsFractionOfImageWidth:4.5/750.0];
        self.sharpnessFactor = 0.4;
        
        CGPoint controlPoint0 = CGPointMake(0, 0);
        CGPoint controlPoint1 = CGPointMake(120/255.0, 146/255.0);
        CGPoint controlPoint2 = CGPointMake(1.0, 1.0);
        
#if TARGET_OS_IOS
        self.controlPoints = @[[NSValue valueWithCGPoint:controlPoint0],
                               [NSValue valueWithCGPoint:controlPoint1],
                               [NSValue valueWithCGPoint:controlPoint2]];
#else
        self.controlPoints = @[[NSValue valueWithPoint:controlPoint0],
                               [NSValue valueWithPoint:controlPoint1],
                               [NSValue valueWithPoint:controlPoint2]];
#endif
    }
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [super setInputSize:newSize atIndex:textureIndex];
    self.currentInputSize = newSize;
    [self updateHighPassRadius];
}

- (void)updateHighPassRadius {
    CGSize inputSize = self.currentInputSize;
    if (inputSize.width * inputSize.height > 0) {
        CGFloat radiusInPixels = 0;
        switch (self.radius.unit) {
            case SDGPUImageHighPassSkinSmoothingRadiusUnitPixel:
                radiusInPixels = self.radius.value;
                break;
            case SDGPUImageHighPassSkinSmoothingRadiusUnitFractionOfImageWidth:
                radiusInPixels = ceil(inputSize.width * self.radius.value);
                break;
            default:
                break;
        }
        if (radiusInPixels != self.maskGenerator.highPassRadiusInPixels) {
            self.maskGenerator.highPassRadiusInPixels = radiusInPixels;
        }
    }
}

- (void)setRadius:(SDGPUImageHighPassSkinSmoothingRadius *)radius {
    _radius = radius.copy;
    [self updateHighPassRadius];
}

- (void)setControlPoints:(NSArray<NSValue *> *)controlPoints {
    self.skinToneCurveFilter.rgbCompositeControlPoints = controlPoints;
}

- (NSArray<NSValue *> *)controlPoints {
    return self.skinToneCurveFilter.rgbCompositeControlPoints;
}

- (void)setAmount:(CGFloat)amount {
    _amount = amount;
    self.dissolveFilter.mix = amount;
    self.sharpenFilter.sharpness = self.sharpnessFactor * amount;
}

- (void)setSharpnessFactor:(CGFloat)sharpnessFactor {
    _sharpnessFactor = sharpnessFactor;
    self.sharpenFilter.sharpness = sharpnessFactor * self.amount;
}

@end
