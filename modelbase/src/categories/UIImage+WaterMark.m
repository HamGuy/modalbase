//
//  UIImage+WaterMark.m
//  modelbase
//
//  Created by HamGuy on 6/6/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "UIImage+WaterMark.h"

@implementation UIImage (WaterMark)

- (UIImage *) imageWithWaterMask:(UIImage*)mask
{
    CGRect rect = CGRectMake(self.size.width - mask.size.width, self.size.height-mask.size.height, mask.size.width, mask.size.height);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    
    //
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //
    [mask drawInRect:rect];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}

@end
