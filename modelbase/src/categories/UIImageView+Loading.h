//
//  UIImageView+Loading.h
//  modelbase
//
//  Created by HamGuy on 5/25/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#define TAG_ACTIVITY_INDICATOR 68773456



@interface UIImageView (Loading)

-(void)setImageShowingActivityIndicatorWithURL:(NSURL *)url;

-(void)setImageShowingActivityIndicatorWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

-(void)setImageShowingActivityIndicatorWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder failed:(void (^)())failedBlock;

@end
