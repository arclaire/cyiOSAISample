//
//  Config.h
//  cyiOSAISample
//
//  Created by Michael on 19/09/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define kScreenWScale(x) [UIScreen mainScreen].bounds.size.width / 375.0 * x
#define kResDirectory ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:kResDir])
#define kWhiteColor [UIColor whiteColor]
#define kSelectedColor @"f79e4d"
#define kNormalColor @"633b17"
#define kBackgroundColor @"ee609a"

#define kSubscribeCheckPsw @"c31948bcb2c14cd0b28a784baa50332b"//@"562f3f6dbc5045428ab14ce828e630b1"

#define Localized(Str) NSLocalizedString(Str, Str)


#define kIsFirstLaunch @"isFirstLaunch"
#define kIsSkipPurchase @"isSkipPurchase"
#define kIsVIPMember @"isVIPMember"


static NSString *kNotifyRoot = @"SotaCamNotifyRoot";
static NSString *kGIFDir = @"SotaCamGIF";
static NSString *kResDir = @"SotaCamRes";
static NSString *kVideoDir = @"SotaCamVideo";
static NSString *kCutoutDir = @"SotaCamCutout";
static NSString *kStickersDir = @"SotaCamStickers";
static NSString *kFrameDir = @"SotaCamFrame";
static NSString *kFiltersDir = @"SotaCamFilters";
static NSString *kDowmsampleOriginImagePath = @"DowmsampleOriginImagePath";

static NSString *kAppID = @"1482761574";
static NSString *kAppsFlyerDevKey = @"o6XxR94NFNcyL6NTzsUrRG";
static NSString *kAppsFlyerOneLink = @"XmYD";

#endif /* Config_h */
