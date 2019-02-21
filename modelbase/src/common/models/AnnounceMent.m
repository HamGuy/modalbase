//
//  AnnounceMent.m
//  modelbase
//
//  Created by HamGuy on 7/3/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "AnnounceMent.h"

@implementation AnnounceMent

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"description"]) {
        self.content = value;
    }else if([key isEqualToString:@"time"]){
        self.time = [value substringToIndex:10];
    }else{
        [super setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
