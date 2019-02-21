//
//  HGBaseCell.m
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGBaseCell.h"

@implementation HGBaseCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

+ (id)cellForTableView:(UITableView *)tableView withStyle:(UITableViewCellStyle)style
{
    NSString *cellID = nil;
    if (style == UITableViewCellStyleDefault)
        cellID = @"UITableViewCellStyleDefault";
    else if (style == UITableViewCellStyleValue1)
        cellID = @"UITableViewCellStyleValue1";
    else if (style == UITableViewCellStyleValue2)
        cellID = @"UITableViewCellStyleValue2";
    else if (style == UITableViewCellStyleSubtitle)
        cellID = @"UITableViewCellStyleSubtitle";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:style reuseIdentifier:cellID];
    }
    return cell;
}

+ (id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib {
    NSString *cellID = [self cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
        cell = nibObjects[0];
    }
    else {
        [(HGBaseCell *)cell reset];
    }
    
    return cell;
}

+ (NSString *)nibName {
    return [self cellIdentifier];
}

+ (UINib *)nib {
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    DLog(@"nib name:%@", [self nibName]);
    return [UINib nibWithNibName:[self nibName] bundle:classBundle];
}

+ (CGFloat)cellHeight {
    return 44.0f;
}

+ (CGFloat)cellHeightForContent:(id)content {
    return [self cellHeight];
}

- (void)setContent:(id)content withIndexPath:(NSIndexPath *)indexPath {
    [self setContent:content withIndexPath:indexPath withTableView:nil];
}

- (void)setContent:(id)content withIndexPath:(NSIndexPath *)indexPath withTableView:(UITableView *)tabelView {
    
}

- (void)reset {
    
}

- (UIView *)normalSeperatorWithColor:(UIColor *)color {
    //使highlight状态下separator不消失，所以用UIControl
    UIControl *graySeperator = [[UIControl alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 0.5f, self.frame.size.width, 0.5f)];
    graySeperator.backgroundColor = color;
    graySeperator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    return graySeperator;
}



@end
