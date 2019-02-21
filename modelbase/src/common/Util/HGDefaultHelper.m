//
//  HGDefaultHelper.m
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGDefaultHelper.h"

@implementation HGDefaultHelper

static NSUserDefaults* userDefault;

+(void)initialize{
    userDefault = [NSUserDefaults standardUserDefaults];
}

+(void)setObject:(id)object forKey:(NSString *)key{
    [userDefault setObject:object forKey:key];
    [userDefault synchronize];
}
+(id)objectForKey:(NSString *)key{
    return [userDefault objectForKey:key];
}

@end
