//
//  HGNavigationController.h
//  modelbase
//
//  Created by HamGuy on 5/15/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HGNavigationBarStyle) {
    HGNavigationBarStyleDefault,
    HGNavigationBarStyleBlack
};

@interface HGNavigationController : UINavigationController

@property (nonatomic, assign) HGNavigationBarStyle navigationBarStyle;

@end
