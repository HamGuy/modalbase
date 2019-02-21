//
//  UIImageView+Rounded.m
//  modelbase
//
//  Created by HamGuy on 6/3/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "UIImageView+Rounded.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (Rounded)

-(void)roundedWithBorderWidth:(CGFloat)width borderColor:(UIColor *)boderColor{
    self.layer.cornerRadius = self.frame.size.width/2.0;
    self.layer.borderWidth = width;
    self.layer.borderColor = [boderColor CGColor];
    self.layer.masksToBounds = YES;
}

@end
