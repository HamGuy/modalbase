//
//  Ablum.h
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *  专辑相关信息
 */
@interface Ablum : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * ablumid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * edit;
@property (nonatomic, retain) NSString * abdescription;
@property (nonatomic, retain) NSString * download;
@property (nonatomic, retain) NSString * good;
@property (nonatomic, assign) NSInteger error;
@property (nonatomic, retain) NSString * datatype;
@property (nonatomic, strong) NSString * quick;
@property (nonatomic, strong) NSDate *time;
/**
 *  0 未点赞 1 已经点赞
 */
@property (nonatomic, assign) NSInteger goodme; 



+(Ablum *)getAblumWithId:(NSString *)aid;
+(NSArray *)getAblumListWithDatatype:(NSString *)datatype;
@end
