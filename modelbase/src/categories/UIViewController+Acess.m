//
//  UIViewController+Acess.m
//  modelbase
//
//  Created by HamGuy on 6/29/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "UIViewController+Acess.h"
#import "HGCurretUserContext.h"
#import "UIAlertView+Block.h"
#import "HGLoginController.h"
#import "HGNavigationController.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@implementation UIViewController (Acess)

-(BOOL)canDownload{
//    return YES;
    if (![self isLogined]) {
        return NO;
    }
    
    BOOL result = [HGCurretUserContext sharedInstance].allowDownload;
    if (!result) {
        [UIAlertView showNoticeWithTitle:@"提示" message:@"对不起，您所在的用户主组没有权限下载该专辑！" cancelButtonTitle:@"确定"];
    }
    return result;
}

-(BOOL)canPreview{
    if (![self isLogined]) {
        return NO;
    }

    
    BOOL result = [HGCurretUserContext sharedInstance].allowPreview;
    if (!result) {
        [UIAlertView showNoticeWithTitle:@"提示" message:@"对不起，您所在的用户组没有权限预览该专辑！" cancelButtonTitle:@"确定"];
    }
    return result;
}

-(BOOL)canEdit{    
    if (![self isLogined]) {
        return NO;
    }
    
    BOOL result = [HGCurretUserContext sharedInstance].allowEdit;
    if (!result) {
        [UIAlertView showNoticeWithTitle:@"提示" message:@"对不起，您所在的用户组没有权限编辑该专辑！" cancelButtonTitle:@"确定"];
    }
    return result;
}

-(BOOL)canUpload{
    
    if (![self isLogined]) {
        return NO;
    }
    
    BOOL result = [HGCurretUserContext sharedInstance].allowUpLoad;
    if (!result) {
//        [UIAlertView showNoticeWithTitle:@"提示" message:@"对不起，您所在的用户组没有权限创建专辑！" cancelButtonTitle:@"确定"];
    }
    return result;
}

-(BOOL)isLogined{
    BOOL result = [HGCurretUserContext sharedInstance].username.length>0;
    if (!result) {
        __weak typeof(self) mySelf = self;
        [UIAlertView showWithTitle:@"提示" message:@"您尚未登录，请登录后再继续操作！" cancelButtonTitle:@"取消" otherButtonTitles:@[@"登录"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                HGNavigationController *nav = [[HGNavigationController alloc] initWithRootViewController:[AppDelegate loginController]];
                [mySelf presentViewController:nav animated:YES completion:nil];
            }
        }];
    }
    return result;
}

-(BOOL)wifiNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

-(BOOL)canPostAnnouce{
    if ([HGCurretUserContext sharedInstance].username.length>0) {
        return  [HGCurretUserContext sharedInstance].allowPostAnnouces;
    }else{
        return NO;
    }
}

-(BOOL)isNetworkEnabled{
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}
@end
