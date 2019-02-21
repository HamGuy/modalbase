//
//  HGuserDetailCell.m
//  modelbase
//
//  Created by HamGuy on 7/5/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGuserDetailCell.h"

@interface HGuserDetailCell ()

@property (nonatomic, weak) IBOutlet UILabel *keyLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) UIView *seperatorView;

@end

@implementation HGuserDetailCell

+(CGFloat)cellHeight{
    return 44.f;
}


-(void)setUpCellWithKey:(NSString *)key andValue:(id)value{
    self.keyLabel.text = key;
    self.valueLabel.text = [value isKindOfClass:[NSString class]] ? value : @"未填写";
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(_seperatorView == nil){
        _seperatorView = [self normalSeperatorWithColor:RGBCOLOR(220, 220, 220)];
        _seperatorView.frame = CGRectMake(8, self.height-1.0f,self.width-16.f, 1.0f);
        [self addSubview:_seperatorView];
    }
}
@end
