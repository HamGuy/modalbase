//
//  Cover.m
//  modelbase
//
//  Created by HamGuy on 5/28/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "Cover.h"
#import "UserInfo.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>


@implementation Cover

@dynamic ablumid;
@dynamic datatype;
@dynamic path;
@dynamic title;
@dynamic userinfo;

+(NSArray *)getCoversByType:(NSString *)type{
    return [Cover MR_findByAttribute:@"datatype" withValue:type];
}

+(NSArray *)getAllCovers{
    return [Cover MR_findAll];
}

+(Cover *)coverForAblum:(NSString *)ablumId{
    NSArray *covers = [Cover MR_findByAttribute:@"ablumid" withValue:ablumId];
    if (covers && covers.count>0) {
        return covers[0];
    }
    return nil;
}

+(Cover *)coverForAblum:(NSString *)ablumId withDataType:(NSString *)datatype{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ablumid == %@ AND datatype == %@",ablumId,datatype];
     return [Cover MR_findFirstWithPredicate:predicate];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    DLog(@"undefinedkey %@ for value : %@ Cover",key,value);
}


@end
