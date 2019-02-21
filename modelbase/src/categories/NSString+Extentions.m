//
//  NSString+Extentions.m
//  modelbase
//
//  Created by HamGuy on 6/6/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "NSString+Extentions.h"

@implementation NSString (Extentions)

-(BOOL)containsString:(NSString *)string
{
    NSRange range = [self rangeOfString:string];
    return range.length!=0;
}

-(NSData *)toDataWithEncoding:(NSStringEncoding)stringEncoding
{
    return [self dataUsingEncoding:stringEncoding];
}

-(NSData *)toUTF8Data
{
    return [self toDataWithEncoding:NSUTF8StringEncoding];
}

@end
