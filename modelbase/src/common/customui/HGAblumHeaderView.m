//
//  HGAblumHeaderView.m
//  modelbase
//
//  Created by HamGuy on 5/18/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumHeaderView.h"

@interface HGAblumHeaderView ()

@property (nonatomic, strong) UIImageView *indicatorView;

@end

@implementation HGAblumHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if(self.titleLabel==nil){
            _control = [[UIControl alloc] initWithFrame:self.bounds];
            
            self.backgroundColor = [UIColor clearColor];
            
            self.indicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconIndecator"]];
            self.indicatorView.frame = CGRectMake(8, 11, 3, 19);
            [_control addSubview:_indicatorView];
            
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 11, 68, 21)];
            self.titleLabel.backgroundColor = [UIColor clearColor];
            
            [_control addSubview:self.titleLabel];
            
            self.navButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.navButton.frame = CGRectMake(231, 11, 84, 21);
            [_control addSubview:self.navButton];
            [self addSubview:_control];
        }

    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    

}

@end
