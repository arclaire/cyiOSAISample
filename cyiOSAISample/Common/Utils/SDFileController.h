//
//  FileController.h
//  cyiOSAISample
//
//  Created by Michael on 23/10/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SDFileController : NSObject
+ (void)createGIFDirectory;
+ (void)createVideoDirectory;
+ (void)createCutoutDirectory;
+ (void)createStickersDirectory;
+ (void)createFiltersDirectory;
+ (void)createFrameDirectory;
+ (NSString *)generateVideoPath;
+ (NSString *)getCutoutPath:(NSString *)filename;
+ (NSString *)getStickersPath:(NSString *)filename;
+ (NSString *)getFiltersPath:(NSString *)filename;
+ (NSString *)getFramePath:(NSString *)filename;
+ (void)deleteFile:(NSString *)filePath;
+ (BOOL)resourceExists:(NSString *)path;
+ (NSString *)getMainBundle:(NSString *)bundleName
               ResourceName:(NSString *)resourceName
                       Type:(NSString *)type;
+ (NSString *)getResourcePath;
+ (NSString *)getResourcePath:(NSString *)filename;

@end

NS_ASSUME_NONNULL_END
