//
//  UserInfo.h
//  modelbase
//
//  Created by HamGuy on 5/28/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cover;

@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * error;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * userdescrption;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSOrderedSet *images;
@property (nonatomic, retain) NSString *head;

+(UserInfo *)userInfoWithUserNmae:(NSString*)username;

@end

@interface UserInfo (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Cover *)value;
- (void)removeImagesObject:(Cover *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
