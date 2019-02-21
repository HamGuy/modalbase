//
//  HGAppDelegate.h
//  modelbase
//
//  Created by HamGuy on 5/15/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGNavigationController.h"
#import "HGHomeViewController.h"
#import "HGAblumListController.h"
#import "HGMessageListController.h"
#import "HGContactUsController.h"
#import "HGUserCenterController.h"
#import "HGLoginController.h"
#import "HGSearchController.h"

@interface HGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) HGNavigationController *centerController;
@property (nonatomic, strong) HGHomeViewController *homeViewController;
@property (nonatomic, strong) HGAblumListController *newsAblumListController;
@property (nonatomic, strong) HGAblumListController *recAblumListController;
@property (nonatomic, strong) HGAblumListController *vipAblumListController;
@property (nonatomic, strong) HGAblumListController *copAblumListController;
@property (nonatomic, strong) HGMessageListController *msgListController;
@property (nonatomic, strong) HGContactUsController *contactUsController;
@property (nonatomic, strong) HGUserCenterController *userCenterController;
@property (nonatomic, strong) HGLoginController *loginController;
@property (nonatomic, strong) HGSearchController *searchController;

@end
