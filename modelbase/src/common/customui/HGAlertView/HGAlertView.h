//
//  HGAlertView.h
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HGAlertViewClickedBlock)(NSInteger buttonIndex);

@interface HGAlertView : UIView

@property (nonatomic, strong) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, strong) UIView *dialogView;    // Dialog's container view
@property (nonatomic, strong) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, strong) UIView *buttonView;    // Buttons on the bottom of the dialog

@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;



- (id)initWithAction:(HGAlertViewClickedBlock)action;


- (void)show;
- (void)close;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

@end
