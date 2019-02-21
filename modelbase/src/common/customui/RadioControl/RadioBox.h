//
//  RadioBox.h
//
//  Created by 凌洛寒 on 14-5-14.
//  Copyright (c) 2014年 凌洛寒. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioBox : UIControl

@property (nonatomic, assign, getter = isOn) BOOL on;
@property (nonatomic) BOOL isClick;
@property (nonatomic, strong) UIColor *onTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *boxColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *boxBgColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *textFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) NSInteger value;

- (void)setOn:(BOOL)on;

@end
