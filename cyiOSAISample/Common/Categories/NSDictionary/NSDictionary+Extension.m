//
//  NSDictionary+Extension.m
//  cyiOSAISample
//
//  Created by Michael on 25/09/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)
- (NSDictionary *)sdRemoveNull {
    NSMutableDictionary *dic = self.mutableCopy;
    for (NSString * key in dic.allKeys) {
        id value = [dic valueForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            value = [value sdRemoveNull];
            [dic setValue:value forKey:key];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [value mutableCopy];
            for (int i= 0; i < array.count; i++) {
                if ([array[i] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = array[i];
                    dic = [dic sdRemoveNull];
                    [array replaceObjectAtIndex:i withObject:dic];
                } else if (array[i] == nil || [array[i] isKindOfClass:[NSNull class]]) {
                    [array replaceObjectAtIndex:i withObject:@""];
                }
                
            }
            [dic setValue:array forKey:key];
        } else if (value == nil || [value isKindOfClass:[NSNull class]]) {
            value = @"";
            [dic setValue:value forKey:key];
        }
    }
    
    return dic;
}
@end
