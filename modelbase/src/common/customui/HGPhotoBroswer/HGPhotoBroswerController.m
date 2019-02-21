//
//  HGPhotoBroswerController.m
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGPhotoBroswerController.h"
#import "MWPhotoBrowser.h"
#import "HGShareViewController.h"
#import "HGPopContainerView.h"
#import "HGPhoto.h"
#import "HGPhotoCaptionView.h"

@interface HGPhotoBroswerController ()

@property (nonatomic, strong) UIViewController *leftViewController;

@end

@implementation HGPhotoBroswerController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.leftViewController = self.mm_drawerController.leftDrawerViewController;
    [self.mm_drawerController setLeftDrawerViewController:nil];
    [((HGNavigationController *)self.navigationController) setNavigationBarStyle:HGNavigationBarStyleBlack];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setLeftDrawerViewController:self.leftViewController];
    [((HGNavigationController *)self.navigationController) setNavigationBarStyle:HGNavigationBarStyleDefault];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(BOOL)prefersStatusBarHidden{
    return !IS_IOS6();
}

@end
