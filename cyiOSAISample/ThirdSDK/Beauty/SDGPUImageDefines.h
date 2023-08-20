//
//  SDGPUImageDefines.h
//  cyiOSAISample
//
//  Created by leni santi on 18/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

#if TARGET_OS_IOS
#define SD_GLSL_PRECISION_HIGH highp
#define SD_GLSL_PRECISION_LOW lowp
#define SD_GLSL_FLOAT_PRECISION_LOW  precision SD_GLSL_PRECISION_LOW float;
#else
#define SD_GLSL_PRECISION_HIGH
#define SD_GLSL_PRECISION_LOW
#define SD_GLSL_FLOAT_PRECISION_LOW
#endif
