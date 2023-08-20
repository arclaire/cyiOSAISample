//
//  PIEMaskRenderer.h
//  pie
//
//  Created by Oleg Poyaganov on 25/05/2017.
//  Copyright © 2017 Oleg Poyaganov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <CoreImage/CoreImage.h>

@interface PIEMaskRenderer : NSObject

@property (nonatomic, strong, nullable) CIImage *inputImage;
@property (nonatomic, strong, nonnull) CIColor *backgroundColor;

@property (nonatomic, strong, readonly, nonnull) id<MTLTexture> maskTexture;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device;

- (BOOL)renderToPixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer;

- (UIImage * _Nullable)renderToImageWithCropRect:(CGRect)cropRect outputSize:(CGSize)outputSize;

@end
