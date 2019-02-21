//
//  Note.h
//  modelbase
//
//  Created by HamGuy on 6/28/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * noteinfo;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * ablumid;

+(NSArray *)allNotesIn:(NSString *)ablumId;
+(Note *)noteAtIndex:(int)index;

@end
