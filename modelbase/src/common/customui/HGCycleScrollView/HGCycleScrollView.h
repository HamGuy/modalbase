//
//  HGCycleScrollView.h
//  modelbase
//
//  Created by HamGuy on 7/3/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HGCycleScrollViewDelegate;
@protocol HGCycleScrollViewDatasource;

@interface HGCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign,setter = setDataource:) id<HGCycleScrollViewDatasource> datasource;
@property (nonatomic,assign,setter = setDelegate:) id<HGCycleScrollViewDelegate> delegate;

- (void)setCurrentSelectPage:(NSInteger)selectPage; //设置初始化页数
- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;

-(void)autoScroll:(NSInteger)offsetY timespan:(NSTimeInterval)timespan;

@end

@protocol HGCycleScrollViewDelegate <NSObject>

@optional
- (void)didClickPage:(HGCycleScrollView *)csView atIndex:(NSInteger)index;
- (void)scrollviewDidChangeNumber;

@end

@protocol HGCycleScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages:(HGCycleScrollView*)scrollView;
- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(HGCycleScrollView*)scrollView;

@end
