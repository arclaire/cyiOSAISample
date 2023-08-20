//
//  SDGPUImageStillImageHighPassFilter.h
//  cyiOSAISample
//
//  Created by leni santi on 18/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import "GPUImageFilter.h"
#import "GPUImageFilterGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDGPUImageStillImageHighPassFilter : GPUImageFilterGroup

@property (nonatomic) CGFloat radiusInPixels;

@end

NS_ASSUME_NONNULL_END
