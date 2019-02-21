//
//  HGAblumInfoCell.m
//  modelbase
//
//  Created by HamGuy on 5/19/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumInfoCell.h"
#import "NSString+LineSpace.h"
#import "Ablum.h"
#import "UIImageView+Loading.h"
#import "HGLocalAblumsManager.h"

@interface HGAblumInfoCell ()


@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionlabel;
@property (nonatomic, weak) IBOutlet UIButton *likeBtn;
@property (nonatomic, weak) IBOutlet UIButton *downloadInfoBtn;
@property (nonatomic, weak) IBOutlet UIButton *downloadOrReadButton;

@end

@implementation HGAblumInfoCell

+(CGFloat)cellHeight{
    return 145.f;
}

-(void)setContent:(id)content withIndexPath:(NSIndexPath *)indexPath{
    Ablum *data = content;
    
    __weak typeof(self) mySelf = self;
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kCoverUrl,data.path];
    [_coverImgView setImageShowingActivityIndicatorWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"BgPlaceHoderSmall"] failed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            mySelf.coverImgView.image = [UIImage imageNamed:@"BgImageFiledSmall"];
        });
    }];
    _titleLabel.text = data.title;
    _authorLabel.text = [NSString stringWithFormat:@"作者：%@",data.edit ? : @"未知"];
    NSString *strDescription = data.abdescription;
    _descriptionlabel.attributedText =[strDescription attributedStringWithLineSpace:3.f];
    
    _likeCountLabel.text = data.good;
    _downloadCountLabel.text = data.download;
    _downloadOrReadButton.tag = indexPath.row;
    [_downloadCountLabel sizeToFit];
    
    [_titleLabel sizeToFit];
    [_authorLabel sizeToFit];
    
    BOOL ablumDownloaded = [[HGLocalAblumsManager sharedInstance] isAlreadyDownLoaded:data.ablumid];
    NSString *btnTitle = ablumDownloaded ? @"立刻阅读" : @"下载";
    [self.downloadOrReadButton setTitle:btnTitle forState:UIControlStateNormal];
    
}

-(IBAction)downLoadOrRead:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"下载"]) {
        self.indicatorContainerView.hidden = NO;
        self.downloadIndicator.progress = 0;
        self.downloadIndicator.trackTintColor = [UIColor whiteColor];
        self.downloadIndicator.progressTintColor = kCommonHoghtedColor;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ablumInfoCell:didClickeButton:)]) {
        [self.delegate ablumInfoCell:self didClickeButton:sender];
    }
}

@end
