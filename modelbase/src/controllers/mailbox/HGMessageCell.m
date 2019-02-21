//
//  HGMessageCell.m
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGMessageCell.h"
#import "HGMessage.h"
#import "AnnounceMent.h"

@interface HGMessageCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *contentLabel;
@end


@implementation HGMessageCell


+(CGFloat)cellHeight{
    return 44.f;
}

-(void)setContent:(id)content withIndexPath:(NSIndexPath *)indexPath{
    if ([content isKindOfClass:[HGMessage class]]) {
        HGMessage *msg = content;
        if (msg){
            self.titleLabel.text = msg.title.length>0 ?msg.title : @"无标题";
            self.nameLabel.text = msg.sender.length>0 ? msg.sender : @"未知";
            self.contentLabel.text = msg.content;
            self.dateTimeLabel.text = msg.time;
        }
    }else{
        AnnounceMent *announcemnet = content;
        self.titleLabel.text = announcemnet.title;
        self.nameLabel.text = announcemnet.sender;
        self.contentLabel.text = announcemnet.content;
        self.dateTimeLabel.text = announcemnet.time;
    }
    self.contentView.backgroundColor = [UIColor whiteColor];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(_seperatorView == nil){
    _seperatorView = [self normalSeperatorWithColor:RGBCOLOR(220, 220, 220)];
        _seperatorView.frame = CGRectMake(8, self.height-0.5f, self.width-16, 0.5f);
        [self addSubview:_seperatorView];
    }
}

@end
