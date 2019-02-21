//
//  Message.m
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGMessage.h"

@implementation HGMessage

@dynamic title;
@dynamic content;
@dynamic sender;
@dynamic time;

-(void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    DLog(@"undefinedkey %@ for value : %@ Message",key,value);
}

+(NSArray *)getAllMessages{
    return [HGMessage MR_findAll];
}

@end
