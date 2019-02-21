//
//  HGAutoImageScroller.h
//  iOSLib
//
//  Created by HamGuy on 4/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGAutoImageScroller;



@protocol HGAutoImageScrollerDatasource <NSObject>
-(NSInteger)imageCount;
-(UIImage *) placeHolderImage;
-(BOOL) autoScroll;
-(CGFloat) animationDuration;

@optional
-(NSString *)imageUrlAtIndex:(NSInteger)index;
-(NSString *)titleForImageAtIndex:(NSInteger)index;

-(UIImage *)localImageAtIndex:(NSInteger)index;
@end

@protocol HGAutoImageScrollerDelegate <NSObject>
@optional
-(void)didClickImageAtIndex:(NSInteger)index;
@end

@interface HGAutoImageScroller : UIView<UIScrollViewDelegate>

@property(nonatomic, weak) IBOutlet id<HGAutoImageScrollerDatasource> datasource;
@property(nonatomic, weak) IBOutlet id<HGAutoImageScrollerDelegate> scrollerDelegate;


-(void) load;

@end
