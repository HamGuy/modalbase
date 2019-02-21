//
//  HGPopContainerView.h
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HGPopContainerAnimationStyle) {
    HGPopContainerAnimationStyleFromBottom,
    HGPopContainerAnimationStyleScaleFade
};

typedef void (^HGPopContainerCompletionBlock)(void);

@interface HGPopContainerView : UIView


+(HGPopContainerView *) sharedContainer;

+(void)showWithView:(UIView *)viewToShow TapToDismiss:(BOOL)tapToDismiss;
+(void)showWithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapToDismiss;
+(void)showWithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapToDismiss animationStyle:(HGPopContainerAnimationStyle)animationStyle;

+(void)showWithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapToDismiss animationStyle:(HGPopContainerAnimationStyle)animationStyle completion:(HGPopContainerCompletionBlock)completionBlock;

+(void)showInparetView:(UIView *)parentView WithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapToDismiss;
+(void)changeSubViewTop:(CGFloat)delta;

+(void)dismiss;

@end
