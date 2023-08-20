//
//  SDGPUImageHighPassSkinSmoothingFilter.h
//  cyiOSAISample
//
//  Created by leni santi on 18/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import "GPUImageFilter.h"
#import "GPUImageFilterGroup.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, SDGPUImageHighPassSkinSmoothingRadiusUnit) {
    SDGPUImageHighPassSkinSmoothingRadiusUnitPixel = 1,
    SDGPUImageHighPassSkinSmoothingRadiusUnitFractionOfImageWidth = 2
};

@interface SDGPUImageHighPassSkinSmoothingRadius : NSObject <NSCopying,NSSecureCoding>

@property (nonatomic,readonly) CGFloat value;
@property (nonatomic,readonly) SDGPUImageHighPassSkinSmoothingRadiusUnit unit;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)radiusInPixels:(CGFloat)pixels;
+ (instancetype)radiusAsFractionOfImageWidth:(CGFloat)fraction;

@end

@interface SDGPUImageHighPassSkinSmoothingFilter : GPUImageFilterGroup

@property (nonatomic) CGFloat amount;

@property (nonatomic,copy) NSArray<NSValue *> *controlPoints; //value of Point

@property (nonatomic,copy) SDGPUImageHighPassSkinSmoothingRadius *radius;

@property (nonatomic) CGFloat sharpnessFactor;

@end

NS_ASSUME_NONNULL_END
