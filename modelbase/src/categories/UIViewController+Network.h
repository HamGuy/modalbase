//
//  UIViewController+Network.h
//  modelbase
//
//  Created by HamGuy on 5/31/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <JDStatusBarNotification/JDStatusBarNotification.h>
#import "UIAlertView+Block.h"

@interface UIViewController (Network)

-(void)loading;
-(void)loadingWithMsg:(NSString *)msg;
-(void)loadingWithMsg:(NSString *)msg progress:(CGFloat)progress;

-(void)successedWitnMessage:(NSString *)message;

-(void)failedWithMessageNotification:(NSString *)message;

-(void)failedWithMessage:(NSString *)message conmpleted:(void (^)(void))failedBlock;

@end
