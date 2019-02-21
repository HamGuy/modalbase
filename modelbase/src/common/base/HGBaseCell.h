//
//  HGBaseCell.h
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HGBaseCell : UITableViewCell

+ (UINib *)nib;

+ (id)cellForTableView:(UITableView *)tableView withStyle:(UITableViewCellStyle)style;
+ (id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib;

+ (NSString *)cellIdentifier;

+ (CGFloat)cellHeight;
+ (CGFloat)cellHeightForContent:(id)content;

- (void)setContent:(id)content withIndexPath:(NSIndexPath *)indexPath;
- (void)setContent:(id)content withIndexPath:(NSIndexPath *)indexPath withTableView:(UITableView *)tabelView;

- (void)reset;
- (UIView *)normalSeperatorWithColor:(UIColor *)color;

@end
