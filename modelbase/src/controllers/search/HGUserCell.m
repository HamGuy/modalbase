//
//  HGUserCell.m
//  modelbase
//
//  Created by HamGuy on 7/4/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGUserCell.h"
#import "UIImageView+Rounded.h"
#import "UIImageView+Loading.h"
#import "UserBrief.h"

@interface HGUserCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *roleImgView;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) UIView *seperatorView;

@end

@implementation HGUserCell

//+(id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib{
//    HGUserCell *cell = [super cellForTableView:tableView fromNib:nib];
//    return cell;
//}


+(CGFloat)cellHeight{
    return 82.f;
}

-(void)setContent:(id)content withIndexPath:(NSIndexPath *)indexPath{
    UserBrief *user = content;
    NSString *avatarUrl = [NSString stringWithFormat:@"%@%@",kBaseImageUrl,user.head];
    [self.avatarView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"IConDefaultAvata"] options:SDWebImageRefreshCached];
    self.titleLabel.text = user.name;
    self.descriptionLabel.text = user.info;
    self.roleImgView.image = [self imageForUserType:user.type];
    if (self.usertype == 1) {
        self.roleImgView.width = 45;
        self.descriptionLabel.left = 134;
    }else{
        self.roleImgView.width = 35;
        self.descriptionLabel.left = 124;    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(_seperatorView == nil){
        [self.avatarView roundedWithBorderWidth:2.0f borderColor:[UIColor whiteColor]];
        _seperatorView = [self normalSeperatorWithColor:RGBCOLOR(205, 205, 204)];
        _seperatorView.frame = CGRectMake(0, self.height-0.5f,self.width, 0.5f);
        [self addSubview:_seperatorView];
    }
}

-(UIImage *)imageForUserType:(NSString *)type{
    if ([type isEqualToString:kUserTypeUser]) {
        return nil;
    }
    
    NSString *imgName = nil;
    if ([type isEqualToString:kUserTypeModel]) {
        imgName = @"IconModel";}
    else if ([type isEqualToString:kUserTypeEditor]) {
        imgName = @"Iconeditor";
    }else if([type isEqualToString:kUserTypeVIP]){
        imgName = @"IconVIP";
    }
    
    return [UIImage imageNamed:imgName];
}

@end
