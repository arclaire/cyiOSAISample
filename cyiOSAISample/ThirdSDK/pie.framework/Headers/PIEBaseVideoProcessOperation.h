//
//  PIEVideoProcessOperation.h
//  pie
//
//  Created by Oleg Poyaganov on 15/03/2017.
//  Copyright © 2017 Oleg Poyaganov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#import "PIEProcessor.h"

extern NSString * const _Nonnull PIEVideoProcessOperationErrorDomain;

@interface PIEBaseVideoProcessOperation : NSOperation

@property (nonatomic, strong, readonly, nonnull) PIEProcessor *processor;
@property (nonatomic, strong, readonly, nullable) PIEModel *model;

@property (nonatomic, strong, readonly, nonnull) AVAsset *asset;
@property (nonatomic, strong, readonly, nonnull) NSURL *destinationURL;

@property (nonatomic, assign, readonly) CGRect clipRect;
@property (nonatomic, assign, readonly) CGSize maxSize;
@property (nonatomic, assign, readonly) NSInteger fps;
@property (nonatomic, assign, readonly) BOOL audio;
@property (nonatomic, assign, readonly) CMTimeRange timeRange;
@property (nonatomic, assign, readonly) CGSize outSize;

@property (nonatomic, copy, nullable) void (^progressCallback)(float);

@property (atomic, strong, readonly, nullable) NSError *error;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
- (instancetype _Nonnull)initWithProcessor:(PIEProcessor * _Nonnull)processor
                                 modelData:(NSData * _Nonnull)modelData
                  modelCircularPaddingConv:(BOOL)modelCircularPaddingConv
                                     asset:(AVAsset * _Nonnull)asset
                            destinationURL:(NSURL * _Nonnull)destinationURL
                                  clipRect:(CGRect)clipRect
                                   maxSize:(CGSize)maxSize
                                       fps:(NSInteger)fps
                                     audio:(BOOL)audio
                                 timeRange:(CMTimeRange)timeRange;

- (void)processImageBuffer:(CVImageBufferRef _Nonnull )imageBuffer;

@end
