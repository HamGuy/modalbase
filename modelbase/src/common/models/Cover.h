//
//  Cover.h
//  modelbase
//
//  Created by HamGuy on 5/28/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface Cover : NSManagedObject

@property (nonatomic, retain) NSString * ablumid;
@property (nonatomic, retain) NSString * datatype;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) UserInfo *userinfo;

+(NSArray *)getCoversByType:(NSString *)type;
//+(NSArray *)getCoversByUser
+(NSArray *)getAllCovers;

+(Cover *)coverForAblum:(NSString *)ablumId;
+(Cover *)coverForAblum:(NSString *)ablumId withDataType:(NSString *)datatype;

@end
