//
//  UIImageView+Loading.m
//  modelbase
//
//  Created by HamGuy on 5/25/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "UIImageView+Loading.h"

@implementation UIImageView (Loading)

- (void)setImageShowingActivityIndicatorWithURL:(NSURL *)url{
    [self setImageShowingActivityIndicatorWithURL:url completed:nil];
}

-(void)setImageShowingActivityIndicatorWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder{
    __block UIActivityIndicatorView* activityIndication = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [activityIndication setFrame:CGRectMake((self.frame.size.width - activityIndication.frame.size.width) / 2 , (self.frame.size.height - activityIndication.frame.size.height) / 2 , activityIndication.frame.size.width , activityIndication.frame.size.width)];
    [self addSubview:activityIndication];
    
    [activityIndication startAnimating];
    
    __weak typeof(self) mySelf = self;
    [self sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(error == nil){
            mySelf.image = image;
        }
        [activityIndication stopAnimating];
        [activityIndication removeFromSuperview];
    }];
}

-(void)setImageShowingActivityIndicatorWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder failed:(void (^)())failedBlock{
    __block UIActivityIndicatorView* activityIndication = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [activityIndication setFrame:CGRectMake((self.frame.size.width - activityIndication.frame.size.width) / 2 , (self.frame.size.height - activityIndication.frame.size.height) / 2 , activityIndication.frame.size.width , activityIndication.frame.size.width)];
    [self addSubview:activityIndication];
    
    [activityIndication startAnimating];
    __weak typeof(self) mySelf = self;
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error==nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                mySelf.image = image;
            });
        }else{
            if (failedBlock) {
                failedBlock();
            }
        }
        [activityIndication stopAnimating];
        [activityIndication removeFromSuperview];
        
    }];
}

- (void)setImageShowingActivityIndicatorWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock
{
    __block UIActivityIndicatorView* activityIndication = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    activityIndication.center = self.center;
    
    [self addSubview:activityIndication];
    
    [activityIndication startAnimating];
    
    __weak typeof(self) mySelf = self;
    [self sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if(completedBlock)
        {
            completedBlock(image,error,cacheType,imageURL);
        }else{
            mySelf.image = image;
        }
        
        [activityIndication stopAnimating];
        [activityIndication removeFromSuperview];
    }];
}
@end
