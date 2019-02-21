//
//  HGNavigationController.m
//  modelbase
//
//  Created by HamGuy on 5/15/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGNavigationController.h"
#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface HGNavigationController ()

@end

@implementation HGNavigationController

-(id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBarStyle = HGNavigationBarStyleDefault;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.navigationBar.translucent = NO;
    
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIColor *titleColor = [UIColor whiteColor];

//    NSString *backgroundImage = IS_IOS6() ? @"TopBar" : @"TopBar7";
//    [self.navigationBar setBackgroundImage:[UIImage imageNamed:backgroundImage] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationBar setClipsToBounds:YES];
        if (!IS_IOS6()) {
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: titleColor}];
        [self setNeedsStatusBarAppearanceUpdate];
    }else {
        [self.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor: titleColor, UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetZero]}];
    }
}

-(void)setNavigationBarStyle:(HGNavigationBarStyle)navigationBarStyle{
    if (navigationBarStyle == HGNavigationBarStyleBlack) {
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"BgTitleBarUpside"] forBarMetrics:UIBarMetricsDefault];
    }else{
        if (IS_IOS6()) {
            [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"TopBar"] forBarMetrics:UIBarMetricsDefault];
        }else {
            [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"TopBar7"] forBarMetrics:UIBarMetricsDefault];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return [self.topViewController disablesAutomaticKeyboardDismissal];
}


- (BOOL)prefersStatusBarHidden {
    return !IS_IOS6();
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}



@end
