//
//  HGImageCroller.m
//  iOSLib
//
//  Created by HamGuy on 4/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAutoImageScroller.h"
#import "UIImageView+Loading.h"
#import "DDPageControl/DDPageControl.h"

#define IMAGE_CONTAINER_TAG 1000

@interface HGAutoImageScroller()
{
    NSInteger currentIndex;
    NSInteger previousIndex;
    NSInteger nextIndex;
    NSInteger totalCount;
}

@property (nonatomic, strong)  UILabel *imageTitleLabel;
@property (nonatomic, strong)  DDPageControl *pageControl;
@property (nonatomic, strong)  UIScrollView *imageContainer;

@end

@implementation HGAutoImageScroller

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self buildImageContainer];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
        [self buildImageContainer];
    }
    return self;
}

-(void)buildImageContainer{
    _imageContainer = [[UIScrollView alloc] initWithFrame:self.frame];
    _imageContainer.left=0;
    _imageContainer.top=0;
    _imageContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _imageContainer.pagingEnabled = YES;
    _imageContainer.showsHorizontalScrollIndicator = NO;
    _imageContainer.showsVerticalScrollIndicator = NO;
    _imageContainer.delegate = self;
    _imageContainer.bounces = NO;
    _imageContainer.tag = IMAGE_CONTAINER_TAG;
    
    [self addSubview:_imageContainer];
    
    [self setupTitleView];
    
}

-(void) setUpImageForImageView:(UIImageView *)imgView withIndex:(int)index
{
    if([self.datasource respondsToSelector:@selector(imageUrlAtIndex:)]){
        NSString *imageUrl = [self.datasource imageUrlAtIndex:index];
        [imgView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[self.datasource placeHolderImage] options:SDWebImageRefreshCached];
    }
    else if([self.datasource respondsToSelector:@selector(localImageAtIndex:)])
    {
        imgView.image = [self.datasource localImageAtIndex:index];
    }
}


-(void) setupTitleView
{
    
    _pageControl = [[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull];
    _pageControl.frame =CGRectMake(self.width - 44, self.height-32, 32, 44);
//    _pageControl.frame =CGRectMake(self.width - 56, self.height- (IS_IOS6() ? 30: 30), 45, 12);
//    _pageControl.center = self.center;
    _pageControl.onColor = kCommonHoghtedColor;
    _pageControl.offColor = [UIColor whiteColor];
    _pageControl.indicatorSpace = 8.f;
    _pageControl.numberOfPages = 0;
    
    [self addSubview:_pageControl];
}

-(void)load{
    //    [_imageContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.datasource) {
        NSInteger imageCount = [self.datasource imageCount];
        _pageControl.numberOfPages = imageCount;
        _pageControl.size = [_pageControl sizeForNumberOfPages:imageCount];
        _pageControl.left -= 8.f;
        _pageControl.top += 2.f;
        _imageContainer.contentSize = CGSizeMake(self.frame.size.width*imageCount, self.frame.size.height);
        totalCount = imageCount;
        
        
        for(int i = 0;i<imageCount;i++){
            CGRect imageFrame = self.imageContainer.bounds;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.height = self.imageContainer.contentSize.height;
            imageView.left = _imageContainer.size.width*i;
            imageView.backgroundColor = RGBCOLOR(203,203,203);
            imageView.image = [self.datasource placeHolderImage];
            imageView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickImageView:)];
            [imageView addGestureRecognizer:tap];
            
            [_imageContainer addSubview:imageView];
            
            if([self.datasource respondsToSelector:@selector(imageUrlAtIndex:)]){
                NSString *imageUrl = [self.datasource imageUrlAtIndex:i];
                [imageView setImageShowingActivityIndicatorWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[self.datasource placeHolderImage]];
            }
            if([self.datasource respondsToSelector:@selector(localImageAtIndex:)]){
                imageView.image = [self.datasource localImageAtIndex:i];
            }
            
            
        }
        //设置第一张图片对应的标题
        if (imageCount>0 && [self.datasource respondsToSelector:@selector(titleForImageAtIndex:)]) {
            _imageTitleLabel.text = [self.datasource titleForImageAtIndex:_pageControl.currentPage];
        }
        [self autoScrollIfNeeded];
    }
}


-(void)didClickImageView:(UITapGestureRecognizer *)tapGesture{
    if (self.scrollerDelegate && [self.scrollerDelegate respondsToSelector:@selector(didClickImageAtIndex:)]) {
        [self.scrollerDelegate didClickImageAtIndex:_pageControl.currentPage];
    }
}

#pragma mark - UIScrollView Delegte
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    self.pageControl.currentPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    [self moveToTargetPage:self.pageControl.currentPage];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGFloat targetX = scrollView.contentOffset.x;
//    CGFloat width = scrollView.width;
//    if (totalCount>=3)
//    {
//        if (targetX >= width * (totalCount -1)) {
//            targetX = width;
//            [scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
//        }
//        else if(targetX <= 0)
//        {
//            targetX = width *(totalCount-2);
//            [scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
//        }
//    }
//    int page = (scrollView.contentOffset.x+width/2.0) / width;
//    //    NSLog(@"%f %d",_scrollView.contentOffset.x,page);
//    if (totalCount> 1)
//    {
//        page --;
//        if (page >= _pageControl.numberOfPages)
//        {
//            page = 0;
//        }else if(page <0)
//        {
//            page = _pageControl.numberOfPages -1;
//        }
//    }
//    _pageControl.currentPage = page;
//}
#pragma mark - Private
- (void)moveToTargetPage:(NSInteger)targetPage
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    CGFloat targetX = targetPage * self.imageContainer.frame.size.width;
    [self moveToTargetPosition:targetX];
    [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:[self.datasource animationDuration]];
}

- (void)switchFocusImageItems
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    
    CGFloat targetX = self.imageContainer.contentOffset.x + self.imageContainer.frame.size.width;
    [self moveToTargetPosition:targetX];
    
    if ([self.datasource autoScroll]) {
        [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:[self.datasource animationDuration]];
    }
}

- (void)moveToTargetPosition:(CGFloat)targetX
{
    //NSLog(@"moveToTargetPosition : %f" , targetX);
    if (targetX >= self.imageContainer.contentSize.width) {
        targetX = 0.0;
    }
    
    __block NSInteger page = _pageControl.currentPage;
    __block NSString *currentTitle = nil;
    if ([self.datasource respondsToSelector:@selector(titleForImageAtIndex:)]) {
        currentTitle = [self.datasource titleForImageAtIndex:page];
    }
    __weak typeof(self) mySelf = self;
    
    [UIView animateWithDuration:0.3f animations:^{
        mySelf.imageContainer.contentOffset = CGPointMake(targetX, 0);
    } completion:^(BOOL finished) {
        _imageTitleLabel.text = currentTitle;
        [mySelf autoScrollIfNeeded];
    }];
    self.pageControl.currentPage = (int)(self.imageContainer.contentOffset.x / self.imageContainer.frame.size.width);
}

-(void) autoScrollIfNeeded
{
    if([self.datasource autoScroll])
        [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:[self.datasource animationDuration]];
}




@end
