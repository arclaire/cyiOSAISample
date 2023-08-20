//
//  NSString+Base64.h
//  cyiOSAISample
//
//  Created by Michael on 19/09/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Base64)
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
@end

NS_ASSUME_NONNULL_END
