//
//  UserDtailInfo.m
//  modelbase
//
//  Created by HamGuy on 7/4/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "UserDtailInfo.h"

@implementation UserDtailInfo

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"description"]) {
        self.userdescription = value;
    }else{
        [super setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
