//
//  Ablum.m
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "Ablum.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@implementation iAblum

@dynamic path;
@dynamic ablumid;
@dynamic title;
@dynamic edit;
@dynamic abdescription;
@dynamic download;
@dynamic good;
@dynamic error;
@dynamic datatype;
@dynamic time;
@dynamic quick;
@dynamic goodme;

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.ablumid = value;
    }else if([key isEqualToString:@"description"]){
        self.abdescription = value;
    }else{
        [super setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    DLog(@"undefinedkey %@ for value : %@ Ablum",key,value);
}


+(Ablum *)getAblumWithId:(NSString *)aid{
    NSArray *result = [Ablum MR_findByAttribute:@"ablumid" withValue:aid];
    if ( result == nil || result.count == 0) {
        return nil;
    }
    return [result objectAtIndex:0];
}

+(NSArray *)getAblumListWithDatatype:(NSString *)datatype{
    return [Ablum MR_findByAttribute:@"datatype" withValue:datatype];
}

@end
