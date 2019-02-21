//
//  NSString+Extentions.h
//  modelbase
//
//  Created by HamGuy on 6/6/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extentions)

-(BOOL) containsString:(NSString *)string;
-(NSData *) toDataWithEncoding:(NSStringEncoding)stringEncoding;
-(NSData *) toUTF8Data;

@end

/*
 1. NSString转化NSData
 
 NSData* aData = [@"a nsstring" dataUsingEncoding: NSUTF8StringEncoding];
 2.NSData转化NSString
 
 NSString* aString = [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
 3.NSString转化char
 
 char cstr[10];
 cstr =[aString UTF8String];
 4.NSData转化char
 
 char* cstr=[aData bytes];
 5.char转化NSString
 
 - (id)initWithUTF8String:(const char *)bytes
 NSString *bString = [[NSString alloc] initWithUTF8String:cstr];
 6.char转化NSData
 
 NSData *data = [NSData dataWithBytes:cstr length:strlen(cstr)];
 */
