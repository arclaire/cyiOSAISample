//
//  SDFilterPackage.h
//  cyiOSAISample
//
//  Created by Michael on 12/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPUImageOutput;
@protocol GPUImageInput;

@interface SDFilterPackage: NSObject
@property (nonatomic, assign) NSInteger filterType;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
- (instancetype)initWithFilter:(GPUImageOutput<GPUImageInput>*)filter filterType:(NSInteger)type;

@end
