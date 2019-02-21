//
//  HGBaseTableViewController.h
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVPullToRefresh/SVPullToRefresh.h>

@interface HGBaseTableViewController : UITableViewController

@property (nonatomic, assign, getter = isDisablePull) BOOL disablePull;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) NSInteger numberOfSections;
@property (nonatomic, assign) BOOL endReached;
@property (nonatomic, assign) NSInteger nextPage;
@property (nonatomic, strong) NSString *noDataTips;

-(void) doRefresh;
-(void) loadMore;

-(void) loadDatas:(BOOL) isFirstPage;
-(UIView *)nilResultViewWithMessage:(NSString *)message;
@end
