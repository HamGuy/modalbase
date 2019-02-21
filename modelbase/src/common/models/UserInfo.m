//
//  UserInfo.m
//  modelbase
//
//  Created by HamGuy on 5/28/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "UserInfo.h"
#import "Cover.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>


@implementation UserInfo

@dynamic error;
@dynamic role;
@dynamic userdescrption;
@dynamic username;
@dynamic images;
@dynamic head;




+(UserInfo *)userInfoWithUserNmae:(NSString*)username{
    return [UserInfo MR_findFirstByAttribute:@"username" withValue:username];
}

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"head"]) {
        if (value) {
            self.head = [NSString stringWithFormat:@"%@%@",kBaseImageUrl,value];
        }
    }
    else
        [super setValue:value forKeyPath:key];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    DLog(@"undefinedkey %@ for value : %@ Userinfo",key,value);
}

@end
