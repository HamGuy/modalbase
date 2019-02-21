//
//  HGAsyncConnection.h
//  modelbase
//
//  Created by HamGuy on 5/20/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HGProgressBlock)(CGFloat progress);
typedef void(^HGCompletedBlock)(NSData *data);
typedef void(^HGErrorBlock)(NSError *error);

@interface HGAsyncConnection : NSURLConnection<NSURLConnectionDataDelegate>

+ (id)request:(NSString *)requestUrl InProgress:(HGProgressBlock)progressBlock OnCompleted:(HGCompletedBlock)completedBlock withError:(HGErrorBlock)errorBlock;

- (id)initWithRequest:(NSString *)requestUrl InProgress:(HGProgressBlock)progressBlock OnCompleted:(HGCompletedBlock)completedBlock withError:(HGErrorBlock)errorBlock;
@end
