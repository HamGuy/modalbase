//
//  HGPathHelper.h
//  modelbase
//
//  Created by HamGuy on 5/31/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/xattr.h>

@interface HGPathHelper : NSObject

+ (NSString *)documentDirectory;
+ (NSString *)cacheDirectory;
+ (NSString *)filePathInDocument:(NSString *)filename;
+ (NSString *)filePathInMainBundle:(NSString *)filename;
+ (NSString *)filePathInCacheDirectory:(NSString *)filename;


+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path;

@end
