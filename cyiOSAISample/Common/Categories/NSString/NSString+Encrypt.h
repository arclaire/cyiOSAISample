//
//  NSString+Encrypt.h
//  cyiOSAISample
//
//  Created by Michael on 19/09/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Encrypt)
- (NSString *)md5;
- (NSString *)hmacMD5withKey:(NSString *)keyStr;
- (NSString *)hmacSHA1withKey:(NSString *)keyStr;
- (NSString *)hmacSHA256withKey:(NSString *)keyStr;
- (NSString *)hmacSHA384withKey:(NSString *)keyStr;
- (NSString *)hmacSHA512withKey:(NSString *)keyStr;
@end

NS_ASSUME_NONNULL_END
