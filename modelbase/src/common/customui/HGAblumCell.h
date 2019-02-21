//
//  HGAblumCell.h
//  modelbase
//
//  Created by HamGuy on 5/18/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGAblumCell;

@protocol HGAblumCellDelagate <NSObject>

@optional
-(void)delButtonCickedOnCell:(HGAblumCell*)cell;

@end

@interface HGAblumCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *delButton;

@property (nonatomic, weak) id<HGAblumCellDelagate> delegate;

+(UINib *) nib;

-(void)changeToEditMode:(BOOL)isEdit;

@end
