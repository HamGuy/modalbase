//
//  HGUploadManager.h
//  modelbase
//
//  Created by HamGuy on 7/2/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^UpLoadPrggressBlock)(CGFloat progress);
typedef void(^UpLoadCompletedBlock)(BOOL success, NSError *error);

@interface HGUploadManager : NSObject

//+(HGUploadManager *) sharedInstance;

-(void)addRequestWithInfo:(NSDictionary *)dict file:(NSString *)fileName tag:(NSInteger)tag;

-(void)sigleRequestWithInfo:(NSDictionary *)dict file:(NSString *)fileName withProigress:(UpLoadPrggressBlock)progressBlock completedBlock:(UpLoadCompletedBlock)completedBlock;

-(void)startploadOperationWithProigress:(UpLoadPrggressBlock)progressBlock completedBlock:(UpLoadCompletedBlock)completedBlock;

-(void)cancelAllOperations;

@end
