//
//  HGPathHelper.m
//  modelbase
//
//  Created by HamGuy on 5/31/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGPathHelper.h"

@implementation HGPathHelper


+ (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
    
}

+ (NSString *)cacheDirectory{
    NSArray *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return cache[0] ;
}

+ (NSString *)filePathInDocument:(NSString *)filename {
    return [[self documentDirectory] stringByAppendingPathComponent:filename];
}
+ (NSString *)filePathInMainBundle:(NSString *)filename{
    if (filename != nil) {
        NSArray *keywords = [filename componentsSeparatedByString:@"."];
        NSString *suffix = keywords[[keywords count]-1];
        NSUInteger length = [filename length] - [suffix length];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:[filename substringToIndex:length-1] ofType:suffix];
        //NSLog(@"%@",path);
        return path;
    }
    return nil;
}

+ (NSString *)filePathInCacheDirectory:(NSString *)filename{
    NSArray *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cache[0] ;
    
    return [cachePath stringByAppendingPathComponent:filename];
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path{
    NSURL *url = [NSURL fileURLWithPath:path];
    
    const char* filePath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}



@end
