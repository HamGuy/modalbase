//
//  HGMMDrawerController.m
//  modelbase
//
//  Created by HamGuy on 5/16/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGMMDrawerController.h"
#import "MMDrawerVisualStateManager.h"

@interface HGMMDrawerController ()

@end

@implementation HGMMDrawerController

-(id)initWithCenterViewController:(UIViewController *)centerViewController leftDrawerViewController:(UIViewController *)leftDrawerViewController{
    self =  [super initWithCenterViewController:centerViewController leftDrawerViewController:leftDrawerViewController];
    if(self){
        self.maximumLeftDrawerWidth = 140.f;
        self.showsShadow = YES;
        [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        [[MMDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeParallax];
        
        
//        self.showsStatusBarBackgroundView = NO;
//        self.statusBarViewBackgroundColor= [UIColor redColor];
        
        [self
         setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
             MMDrawerControllerDrawerVisualStateBlock block;
             block = [[MMDrawerVisualStateManager sharedManager]
                      drawerVisualStateBlockForDrawerSide:drawerSide];
             if(block){
                 block(drawerController, drawerSide, percentVisible);
             }
         }];
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(UIViewController *)childViewControllerForStatusBarHidden{
    return nil;
}

-(UIViewController *)childViewControllerForStatusBarStyle{
    return nil;
}

-(void)setDrawerVisualStateBlock:(void (^)(MMDrawerController *, MMDrawerSide, CGFloat))drawerVisualStateBlock{
    [super setDrawerVisualStateBlock:drawerVisualStateBlock];
}

@end
