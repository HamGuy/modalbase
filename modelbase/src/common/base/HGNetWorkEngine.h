//
//  HGNetWorkEngine.h
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "MKNetworkEngine.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

typedef void(^HGPageAbleSuccessRequestBlock)(MKNetworkOperation* completedOperation, NSArray *result,NSInteger totalPage);

typedef void (^OperationSuccessBlock)(MKNetworkOperation* completedOperation,id result);


@interface HGNetWorkEngine : MKNetworkEngine

@property(nonatomic, strong) NSMutableArray *workingOperations;

-(MKNetworkOperation *)postOperationParams:(NSDictionary *)paras successBlock:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

-(MKNetworkOperation *)downLoadOperationWithParams:(NSDictionary *)paras toFilePath:(NSString *)filePath progress:(MKNKProgressBlock)progressBlock successBlock:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

-(MKNetworkOperation *)uploadImage:(NSDictionary *)dict file:(NSString *)file progress:(MKNKProgressBlock)progressBlock successBlock:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

-(MKNetworkOperation *)uploadImage:(NSDictionary *)dict data:(NSData *)data progress:(MKNKProgressBlock)progressBlock successBlock:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

- (void)cancelAllOperations;
-(NSDate *)dateFrromString:(NSString *)strDat;

-(NSString *)stringFromObject:(id)obj;
@end
