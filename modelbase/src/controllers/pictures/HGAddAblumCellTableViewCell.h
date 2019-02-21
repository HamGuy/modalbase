//
//  HGAddAblumCellTableViewCell.h
//  modelbase
//
//  Created by HamGuy on 6/7/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGAddAblumCellTableViewCell;

@protocol HGAddAblumCellTableViewCellDelegate <NSObject>

-(void)didClikedCell:(HGAddAblumCellTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface HGAddAblumCellTableViewCell : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (strong, nonatomic) id imageData;
@property (nonatomic, assign) BOOL cover;
@property (nonatomic, weak) id<HGAddAblumCellTableViewCellDelegate> delegate;

+(UINib *)nib;

@end
