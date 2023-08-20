//
//  PIESegmentationVideoProcessOperation.h
//  pie
//
//  Created by Oleg Poyaganov on 25/05/2017.
//  Copyright © 2017 Oleg Poyaganov. All rights reserved.
//

#import "PIEBaseVideoProcessOperation.h"

@interface PIESegmentationVideoProcessOperation : PIEBaseVideoProcessOperation

@property (nonatomic, assign) NSInteger modelMinWidth;
@property (nonatomic, assign) NSInteger modelRatio;

- (instancetype _Nonnull)initWithProcessor:(PIEProcessor * _Nonnull)processor
                                    device:(id<MTLDevice> _Nonnull)device
                             modelMinWidth:(NSInteger)modelMinWidth
                                modelRatio:(NSInteger)modelRatio
                                 modelData:(NSData * _Nonnull)modelData
                                     asset:(AVAsset * _Nonnull)asset
                            destinationURL:(NSURL * _Nonnull)destinationURL
                                  clipRect:(CGRect)clipRect
                                   maxSize:(CGSize)maxSize
                                       fps:(NSInteger)fps
                                     audio:(BOOL)audio
                                 timeRange:(CMTimeRange)timeRange;
@end
