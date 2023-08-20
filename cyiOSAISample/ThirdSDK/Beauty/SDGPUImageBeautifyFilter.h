//
//  SDGPUImageBeautifyFilter.h
//  cyiOSAISample
//
//  Created by leni santi on 19/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

NS_ASSUME_NONNULL_BEGIN

@class GPUImageCombinationFilter;

@interface SDGPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageLanczosResamplingFilter *lanczosResamplingFilter;
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

@end

NS_ASSUME_NONNULL_END
