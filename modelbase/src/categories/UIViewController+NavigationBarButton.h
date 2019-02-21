//
//  UIViewController+NavigationBarButton.h
//  modelbase
//
//  Created by HamGuy on 5/16/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationBarButton)

-(void)addbackButtonWithAction:(SEL)action;
-(void)addMoreButton;

-(void)addLeftButtonWithImage:(UIImage *)image highlight:(UIImage*)highlightImage action:(SEL)action;
-(void)addRightButtonWithImage:(UIImage *)image highlight:(UIImage*)highlightImage action:(SEL)action;

-(void)addLeftBarButtonWithName:(NSString *)name withAction:(SEL)action;
-(void)addRightBarButtonWithName:(NSString *)name withAction:(SEL)action;


@end
