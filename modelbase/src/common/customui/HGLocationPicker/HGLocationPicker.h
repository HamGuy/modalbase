//
//  HGLocationPicker.h
//  modelbase
//
//  Created by HamGuy on 5/30/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGLocation.h"

@class HGLocationPicker;

@protocol HGLocationPickerDelegate <NSObject>

-(void)locationPicker:(HGLocationPicker *)locationPicker didSelectLocation:(HGLocation *)location;

@end


@interface HGLocationPicker : UIView

@property (strong, nonatomic, readonly) HGLocation *location;

-(id)initWithDelegate:(id<HGLocationPickerDelegate>)delegate;
//- (void)showInView:(UIView *)view;


@end
