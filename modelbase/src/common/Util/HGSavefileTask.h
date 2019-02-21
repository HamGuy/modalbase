//
//  HGSavefileTask.h
//  modelbase
//
//  Created by HamGuy on 7/8/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^OPCompletedBlock)(NSString *fileNmae);

@interface HGSavefileTask : NSOperation

-(id)initWithAlasset:(ALAsset *)alasset userInfo:(NSDictionary *)userInfo complted:(OPCompletedBlock)completedBlock;

@end
