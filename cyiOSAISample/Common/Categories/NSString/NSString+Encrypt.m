//
//  NSString+Encrypt.m
//  cyiOSAISample
//
//  Created by Michael on 19/09/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import "NSString+Encrypt.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Encrypt)
- (NSString *)md5 {
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}
- (NSString *)hmacMD5withKey:(NSString *)keyStr {
    const char *cKey  = [keyStr cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [self cStringUsingEncoding:NSUTF8StringEncoding];
    const unsigned int blockSize = 64;
    char ipad[blockSize];
    char opad[blockSize];
    char keypad[blockSize];
    unsigned long keyLen = strlen(cKey);
    CC_MD5_CTX ctxt;
    if (keyLen > blockSize) {
        CC_MD5_Init(&ctxt);
        CC_MD5_Update(&ctxt, cKey, (CC_LONG)keyLen);
        CC_MD5_Final((unsigned char *)keypad, &ctxt);
        keyLen = CC_MD5_DIGEST_LENGTH;
    }
    else {
        memcpy(keypad, cKey, keyLen);
    }
    memset(ipad, 0x36, blockSize);
    memset(opad, 0x5c, blockSize);
    
    int i;
    for (i = 0; i < keyLen; i++) {
        ipad[i] ^= keypad[i];
        opad[i] ^= keypad[i];
    }
    
    CC_MD5_Init(&ctxt);
    CC_MD5_Update(&ctxt, ipad, blockSize);
    CC_MD5_Update(&ctxt, cData, (CC_LONG)strlen(cData));
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(md5, &ctxt);
    
    CC_MD5_Init(&ctxt);
    CC_MD5_Update(&ctxt, opad, blockSize);
    CC_MD5_Update(&ctxt, md5, CC_MD5_DIGEST_LENGTH);
    CC_MD5_Final(md5, &ctxt);
    
    const unsigned int hex_len = CC_MD5_DIGEST_LENGTH*2+2;
    char hex[hex_len];
    for(i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        snprintf(&hex[i*2], hex_len-i*2, "%02x", md5[i]);
    }
    NSData *HMAC = [[NSData alloc] initWithBytes:hex length:strlen(hex)];
    NSString *hash = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
    
    return [hash uppercaseString];
}
- (NSString *)hmacSHA1withKey:(NSString *)keyStr {
    NSData *secretData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < sizeof(result); count++) {
        [outputString appendFormat:@"%02x",result[count]];
    }
    
    return [outputString uppercaseString];
}
- (NSString *)hmacSHA256withKey:(NSString *)keyStr {
    
    const char *cKey  = [keyStr cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_SHA256_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",cHMAC[count]];
    }
    
    return [outputString uppercaseString];
}
- (NSString *)hmacSHA384withKey:(NSString *)keyStr {
    const char *cKey  = [keyStr cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA384_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA384, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_SHA384_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",cHMAC[count]];
    }
    
    return [outputString uppercaseString];
}
- (NSString *)hmacSHA512withKey:(NSString *)keyStr {
    const char *cKey  = [keyStr cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_SHA512_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",cHMAC[count]];
    }
    
    return [outputString uppercaseString];
}
@end
