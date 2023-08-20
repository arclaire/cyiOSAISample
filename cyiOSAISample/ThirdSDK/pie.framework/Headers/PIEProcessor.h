//
//  PIEImageProcessor.h
//  pie
//
//  Created by Oleg Poyaganov on 11/03/2017.
//  Copyright © 2017 Oleg Poyaganov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface PIEModel : NSObject

@end

@interface PIEProfile : NSObject

@property (nonatomic, readonly) CFTimeInterval gpuTime;
@property (nonatomic, readonly) CFTimeInterval cpuTime;

@end

@interface PIEProcessor : NSObject

+ (nonnull NSString *)version;

@property (nonatomic, readonly, nonnull) NSString *backendName;
@property (nonatomic, strong, nullable) PIEProfile *profile;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithDevice:(nullable id<MTLDevice>)device;
- (nonnull instancetype)initWithDevice:(nullable id<MTLDevice>)device commandQueue:(nullable id<MTLCommandQueue>)commandQueue;
- (nonnull instancetype)initWithDevice:(nullable id<MTLDevice>)device
                          commandQueue:(nullable id<MTLCommandQueue>)commandQueue
                       inFlightBuffers:(NSInteger)inFlightBuffers;

- (nonnull PIEModel *)loadModelFromData:(nonnull NSData *)data useCircularPaddingConvolution:(BOOL)useCircularPadding;

- (nonnull CGImageRef)styleTransferWithImage:(nonnull CGImageRef)image model:(nonnull PIEModel *)model;
- (nonnull CGImageRef)styleTransferWithImage:(nonnull CGImageRef)image
                                       model:(nonnull PIEModel *)model
                                tileSideSize:(NSUInteger)tileSideSize
                                overlapSize:(NSUInteger)overlapSize;

typedef NS_OPTIONS(NSUInteger, PIETilingMaskGradient) {
    PIETilingMaskGradientNone   = 0,
    PIETilingMaskGradientLeft   = 1 << 0,
    PIETilingMaskGradientTop    = 1 << 1
};

// in place style transfer
- (void)styleTransferWithPixelBuffer:(nonnull CVPixelBufferRef)buffer model:(nonnull PIEModel *)model;


- (nonnull CGImageRef)segmentationWithImage:(nonnull CGImageRef)image model:(nonnull PIEModel *)model;
- (nonnull CGImageRef)segmentationWithImage:(nonnull CGImageRef)image model:(nonnull PIEModel *)model minWidth:(NSInteger)minWidth ratio:(NSInteger)ratio;

- (nonnull CGImageRef)segmentationWithImage:(nonnull CGImageRef)image
                                      model:(nonnull PIEModel *)model
                                   minWidth:(NSInteger)minWidth
                                      ratio:(NSInteger)ratio
                                maskChannel:(NSInteger)maskChannel;

- (nonnull CGImageRef)matteWithImage:(nonnull CGImageRef)image
                               model:(nonnull PIEModel *)model
                            minWidth:(NSInteger)minWidth
                               ratio:(NSInteger)ratio;

#if !(TARGET_OS_SIMULATOR)
- (void)segmentationWithPixelBuffer:(nonnull CVPixelBufferRef)buffer
                       displayLayer:(nonnull CAMetalLayer *)displayLayer
                              model:(nonnull PIEModel *)model
                           minWidth:(NSInteger)minWidth
                              ratio:(NSInteger)ratio;

- (void)segmentationWithPixelBuffer:(nonnull CVPixelBufferRef)buffer
                      outputTexture:(nonnull id<MTLTexture>)outputTexture
                              model:(nonnull PIEModel *)model
                             isLive:(BOOL)isLive
                           minWidth:(NSInteger)minWidth
                              ratio:(NSInteger)ratio;

- (void)styleTransferWithPixelBuffer:(nonnull CVPixelBufferRef)buffer
                        displayLayer:(nonnull CAMetalLayer *)displayLayer
                               model:(nonnull PIEModel *)model;

- (nonnull NSArray*)classificationWithPixelBuffer:(nonnull CVPixelBufferRef)buffer
                                            model:(nonnull PIEModel *)model;

- (nonnull NSArray*)classificationWithImage:(nonnull CGImageRef)image
                                      model:(nonnull PIEModel *)model
                               classesCount:(NSInteger)classesCount;

- (nonnull NSArray*)classificationMultipleOutputWithImage:(nonnull CGImageRef)image
                                                    model:(nonnull PIEModel *)model
                                        classesCount:(nonnull NSArray *)classesCount;


#endif

@end
