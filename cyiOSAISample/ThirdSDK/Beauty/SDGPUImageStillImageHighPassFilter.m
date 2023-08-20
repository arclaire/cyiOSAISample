//
//  SDGPUImageStillImageHighPassFilter.m
//  cyiOSAISample
//
//  Created by leni santi on 18/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import "SDGPUImageStillImageHighPassFilter.h"

#import "SDGPUImageStillImageHighPassFilter.h"
#import "SDGPUImageDefines.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageTwoInputFilter.h"

NSString * const SDGPUImageStillImageHighPassFilterFragmentShaderString = SHADER_STRING(
 SD_GLSL_FLOAT_PRECISION_LOW
 varying SD_GLSL_PRECISION_HIGH vec2 textureCoordinate;
 varying SD_GLSL_PRECISION_HIGH vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main() {
     vec4 image = texture2D(inputImageTexture, textureCoordinate);
     vec4 blurredImage = texture2D(inputImageTexture2, textureCoordinate);
     gl_FragColor = vec4((image.rgb - blurredImage.rgb + vec3(0.5,0.5,0.5)), image.a);
 }
);

@interface SDGPUImageStillImageHighPassFilter ()

@property (nonatomic,weak) GPUImageGaussianBlurFilter *blurFilter;

@end

@implementation SDGPUImageStillImageHighPassFilter

- (instancetype)init {
    if (self = [super init]) {
        GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        [self addFilter:blurFilter];
        self.blurFilter = blurFilter;
        
        GPUImageTwoInputFilter *filter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:SDGPUImageStillImageHighPassFilterFragmentShaderString];
        [self addFilter:filter];
        
        [blurFilter addTarget:filter atTextureLocation:1];
        
        self.initialFilters = @[blurFilter,filter];
        self.terminalFilter = filter;
    }
    return self;
}

- (void)setRadiusInPixels:(CGFloat)radiusInPixels {
    self.blurFilter.blurRadiusInPixels = radiusInPixels;
}

- (CGFloat)radiusInPixels {
    return self.blurFilter.blurRadiusInPixels;
}

@end
