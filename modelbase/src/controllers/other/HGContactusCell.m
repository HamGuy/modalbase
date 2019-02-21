//
//  HGContactusCell.m
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGContactusCell.h"

@interface HGContactusCell ()

@end

@implementation HGContactusCell

+(CGFloat)cellHeight{
    return 44.f;
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
