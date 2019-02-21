//
//  HGAblumInfoCell.h
//  modelbase
//
//  Created by HamGuy on 5/19/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGBaseCell.h"
#import "DACircularProgressView.h"

@class HGAblumInfoCell;

@protocol HGAblumInfoCellDelegate <NSObject>

@optional
-(void)ablumInfoCell:(HGAblumInfoCell*)cell didClickeButton:(UIButton *)btn;

-(void)ablumInfoCell:(HGAblumInfoCell *)cell didClickAuthor:(NSString *)author;
@end

@interface HGAblumInfoCell : HGBaseCell

@property (weak, nonatomic) id<HGAblumInfoCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *coverImgView;
@property (nonatomic, strong) IBOutlet UIView *indicatorContainerView;
@property (nonatomic, strong) IBOutlet DACircularProgressView *downloadIndicator;
@property (nonatomic, strong) IBOutlet UILabel *likeCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *downloadCountLabel;

@end
