//
//  UIViewController+Network.m
//  modelbase
//
//  Created by HamGuy on 5/31/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "UIViewController+Network.h"

static MBProgressHUD *hud;

@implementation UIViewController (Network)

-(void)loading{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


-(void)loadingWithMsg:(NSString *)msg{
    [self hud].labelText = msg;
    [self hud].mode = MBProgressHUDModeIndeterminate;
    if ([[self hud] isHidden]) {
        [[self hud] show:YES];
    }
}

-(void)loadingWithMsg:(NSString *)msg progress:(CGFloat)progress{
    [self hud].labelText = msg;
    [self hud].mode = MBProgressHUDModeDeterminate;
    [self hud].progress = progress;
    if ([[self hud] isHidden]) {
        [[self hud] show:YES];
    }
}

-(void)successedWitnMessage:(NSString *)message{
    if ([self hud]) {
        [[self hud] hide:YES];
        hud = nil;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (message) {
        [JDStatusBarNotification showWithStatus:message dismissAfter:2.0f styleName:JDStatusBarStyleError];
    }
}

-(void)failedWithMessageNotification:(NSString *)message{
    if ([self hud]) {
        [[self hud] hide:YES];
        hud = nil;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (message) {
        [JDStatusBarNotification showWithStatus:message dismissAfter:2.0f styleName:JDStatusBarStyleDark];
    }

}

-(void)failedWithMessage:(NSString *)message conmpleted:(void (^)(void))failedBlock{
    if ([self hud]) {
        [[self hud] hide:YES];
        hud = nil;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (message) {
        [UIAlertView showWithTitle:@"提示" message:message cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (failedBlock) {
                failedBlock();
            }
        }];
    }
}

-(MBProgressHUD *)hud{
    if (hud == nil) {
        hud = [MBProgressHUD HUDForView:self.view];
    }
    return hud;
}
@end
