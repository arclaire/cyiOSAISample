//
//  SDFilterPackage.m
//  cyiOSAISample
//
//  Created by Michael on 12/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import "SDFilterPackage.h"

@implementation SDFilterPackage
- (instancetype)initWithFilter:(GPUImageOutput<GPUImageInput>*)filter filterType:(NSInteger)type {
    if (self = [super init]) {
        self.filter = filter;
        self.filterType = type;
    }
    return self;
}
@end
