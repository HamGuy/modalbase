//
//  HGPopContainerView.m
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGPopContainerView.h"
#import <QuartzCore/QuartzCore.h>



//static CGFloat animationDuratio

@interface HGPopContainerView ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *viewToShow;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) HGPopContainerAnimationStyle animationStyle;
@property (nonatomic, copy) HGPopContainerCompletionBlock completionBlock;

@end

@implementation HGPopContainerView

+(HGPopContainerView *)sharedContainer{
    static dispatch_once_t once;
    static HGPopContainerView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

#pragma mark - Class Methods
+(void)showWithView:(UIView *)viewToShow TapToDismiss:(BOOL)tapToDismiss{
    if ([self isVisible]) {
        return;
    }
    
    [[self sharedContainer] showInParentView:nil WithView:viewToShow animtionDuration:0.5f TapToDismiss:tapToDismiss animationStyle:HGPopContainerAnimationStyleFromBottom completion:nil];
}

+(void)showWithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapToDismiss{
    [[self sharedContainer] showInParentView:nil WithView:viewToShow animtionDuration:duration TapToDismiss:tapToDismiss animationStyle:HGPopContainerAnimationStyleFromBottom completion:nil];
}

+(void)showWithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapToDismiss animationStyle:(HGPopContainerAnimationStyle)animationStyle{
    [[self sharedContainer] showInParentView:nil WithView:viewToShow animtionDuration:duration TapToDismiss:tapToDismiss animationStyle:animationStyle completion:nil];
}

+(void)showWithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapToDismiss animationStyle:(HGPopContainerAnimationStyle)animationStyle completion:(HGPopContainerCompletionBlock)completionBlock{
    [[self sharedContainer] showInParentView:nil WithView:viewToShow animtionDuration:duration TapToDismiss:tapToDismiss animationStyle:animationStyle completion:completionBlock];
}

+(void)showInparetView:(UIView *)parentView WithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapToDismiss{
    [[self sharedContainer] showInParentView:parentView WithView:viewToShow animtionDuration:duration TapToDismiss:tapToDismiss animationStyle:HGPopContainerAnimationStyleScaleFade completion:nil];
}

+(void)changeSubViewTop:(CGFloat)delta{
    [self sharedContainer].viewToShow.top += delta;
}

+(void)dismiss{
    
    if ([self isVisible]) {
        [[self sharedContainer] dismiss];
    }
}


#pragma mark - Setters



-(UITapGestureRecognizer *)tapGesture{
    if(_tapGesture == nil){
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMask)];
    }
    return _tapGesture;
}

-(UIView *)maskView{
    if(_maskView == nil){
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.userInteractionEnabled = YES;
        _maskView.alpha = 0.f;
    }
    return _maskView;
}

#pragma mark - Private
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 1;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
	
    return self;
}

-(void)showInParentView:(UIView *)parentView WithView:(UIView *)viewToShow animtionDuration:(CGFloat)duration TapToDismiss:(BOOL)tapDismiss animationStyle:(HGPopContainerAnimationStyle)animationStyle completion:(HGPopContainerCompletionBlock)completionBlock{
    
    self.viewToShow.transform = CGAffineTransformScale(self.viewToShow.transform, 1.0f, 1.0f);
    
    if([self.gestureRecognizers containsObject:self.tapGesture]){
        [self removeGestureRecognizer:self.tapGesture];
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addSubview:self.maskView];
    self.viewToShow = viewToShow;
    
    [self addSubview:viewToShow];
    
    self.animationDuration = duration;
    self.animationStyle = animationStyle;
    self.completionBlock = completionBlock;
    
    if(tapDismiss){
        [self addGestureRecognizer:self.tapGesture];
    }
    if (parentView) {
        [parentView addSubview:self];
    }
    else{
        [[AppDelegate window] addSubview:self];
    }
    
    __weak typeof(self) mySelf = self;
    if (animationStyle == HGPopContainerAnimationStyleFromBottom) {
        viewToShow.top = SCREEN_HEIGHT;
        [UIView animateWithDuration:duration animations:^{
            mySelf.viewToShow.top = SCREEN_HEIGHT - mySelf.viewToShow.height;
            mySelf.maskView.alpha = 0.5f;
        } completion:^(BOOL finished) {
            
        }];
    }
    if (animationStyle == HGPopContainerAnimationStyleScaleFade) {
        self.viewToShow.center = self.center;
        self.viewToShow.alpha = 0.f;
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        NSValue *scale1Value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5f, 0.5f, 1.0f)];
        NSValue *scale2Value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)];
        NSValue *scale3Value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)];
        NSValue *scale4Value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)];
        NSArray *frameValues = [NSArray arrayWithObjects:scale1Value, scale2Value, scale3Value, scale4Value, nil];
        [animation setValues:frameValues];
        
        NSNumber *time1 = [NSNumber numberWithFloat:0.0f];
        NSNumber *time2 = [NSNumber numberWithFloat:0.5f];
        NSNumber *time3 = [NSNumber numberWithFloat:0.9f];
        NSNumber *time4 = [NSNumber numberWithFloat:1.0f];
        NSArray *frameTimes = [NSArray arrayWithObjects:time1, time2, time3, time4, nil];
        [animation setKeyTimes:frameTimes];
        
        animation.fillMode = kCAFillModeForwards;
        animation.duration = duration;
        animation.removedOnCompletion = NO;
        
        [UIView animateWithDuration:self.animationDuration animations:^{
            mySelf.viewToShow.alpha = 1.0f;
            [mySelf.viewToShow.layer addAnimation:animation forKey:@"popup"];
            mySelf.maskView.alpha = 0.5f;
        } completion:^(BOOL finished) {
            if (mySelf.completionBlock) {
                mySelf.completionBlock();
            }
        }];
    }
    
}

-(void)dismiss{
    
    __weak typeof(self) mySelf = self;
    if (self.animationStyle == HGPopContainerAnimationStyleFromBottom) {
        
        [UIView animateWithDuration:self.animationDuration animations:^{
            mySelf.viewToShow.top = SCREEN_HEIGHT;
            mySelf.maskView.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            [mySelf  removeFromSuperview];
        }];
    }
    if (self.animationStyle == HGPopContainerAnimationStyleScaleFade) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        NSValue *scale4Value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1f, 0.1f, 1.0f)];
        NSValue *scale1Value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)];
        NSValue *scale2Value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)];
        NSValue *scale3Value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.6f, 0.6f, 1.0f)];
        NSArray *frameValues = [NSArray arrayWithObjects:scale1Value, scale2Value, scale3Value, scale4Value, nil];
        [animation setValues:frameValues];
        
        NSNumber *time1 = [NSNumber numberWithFloat:0.0f];
        NSNumber *time2 = [NSNumber numberWithFloat:0.5f];
        NSNumber *time3 = [NSNumber numberWithFloat:0.9f];
        NSNumber *time4 = [NSNumber numberWithFloat:1.0f];
        NSArray *frameTimes = [NSArray arrayWithObjects:time1, time2, time3, time4, nil];
        [animation setKeyTimes:frameTimes];
        
        animation.fillMode = kCAFillModeForwards;
        animation.duration = self.animationDuration;
        animation.removedOnCompletion = NO;
        
        [UIView animateWithDuration:self.animationDuration animations:^{
            mySelf.viewToShow.alpha = 0.0f;
            [mySelf.viewToShow.layer addAnimation:animation forKey:@"popup"];
            mySelf.maskView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [mySelf removeFromSuperview];
        }];
    }
}

+ (BOOL)isVisible
{
    return ([self sharedContainer].maskView.alpha != 0);
}


-(void)tapMask{
    [self dismiss];
}

#pragma mark - Animationdelegate

@end
