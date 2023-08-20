//
//  FileController.m
//  cyiOSAISample
//
//  Created by Michael on 23/10/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#import "SDFileController.h"
#import "Config.h"

@implementation SDFileController
+ (void)createGIFDirectory {
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsDirectory stringByAppendingPathComponent:kGIFDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
+ (void)createVideoDirectory {
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsDirectory stringByAppendingPathComponent:kVideoDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
+ (void)createCutoutDirectory {
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsDirectory stringByAppendingPathComponent:kCutoutDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
+ (void)createStickersDirectory {
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsDirectory stringByAppendingPathComponent:kStickersDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
+ (void)createFiltersDirectory {
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsDirectory stringByAppendingPathComponent:kFiltersDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
+ (void)createFrameDirectory {
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsDirectory stringByAppendingPathComponent:kFrameDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
+ (NSString *)generateVideoPath {
    long random = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:kVideoDir];
    NSString *videoPath = [[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", random]] stringByAppendingString:@".m4v"];
    return videoPath;
}
+ (NSString *)getCutoutPath:(NSString *)filename {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:kCutoutDir];
    NSString *cutoutPath = [path stringByAppendingPathComponent:filename];
    return cutoutPath;
}
+ (NSString *)getStickersPath:(NSString *)filename {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:kStickersDir];
    NSString *stickersPath = [path stringByAppendingPathComponent:filename];
    return stickersPath;
}
+ (NSString *)getFiltersPath:(NSString *)filename {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:kFiltersDir];
    NSString *filterLookupPath = [path stringByAppendingPathComponent:filename];
    return filterLookupPath;
}
+ (NSString *)getFramePath:(NSString *)filename {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:kFrameDir];
    NSString *stickersPath = [path stringByAppendingPathComponent:filename];
    return stickersPath;
}
+ (void)deleteFile:(NSString *)filePath {
    NSError *error = nil;
    BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (isExit) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
}
+ (BOOL)writeFile:(id)file fileName:(NSString *)fileName toPath:(NSString *)path fullPath:(NSString **)fullPath {
    BOOL ret = NO;
    NSString *mainPath = [NSString stringWithFormat:@"%@/Library/Caches/", NSHomeDirectory()];
    NSString *direction = [mainPath stringByAppendingString:path];
    [SDFileController directoryWithPath:direction];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", direction, fileName];
    *fullPath = filePath;
    if ([file isKindOfClass:[NSString class]]) {
        NSString *tempFile = (NSString *)file;
        ret = [tempFile writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        ret = [file writeToFile:filePath atomically:YES];
    }
    return ret;
}
+ (BOOL)directoryWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = NO;
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    ret = existed;
    if (!(isDir == YES && existed == YES)) {
        ret = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    return ret;
}
+ (BOOL)resourceExists:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if  ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        return true;
    }
    return false;
}
+ (NSString *)getMainBundle:(NSString *)bundleName
               ResourceName:(NSString *)resourceName
                       Type:(NSString *)type {
    return [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]] pathForResource:resourceName ofType:type];
}
+ (NSString *)getResourcePath {
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsDirectory stringByAppendingPathComponent:kResDir];

    return filePath;
}
+ (NSString *)getResourcePath:(NSString *)filename {
    return [[SDFileController getResourcePath] stringByAppendingPathComponent:filename];
}

@end
