//
//  HGPhotoCaptionView.m
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGPhotoCaptionView.h"

@interface HGPhotoCaptionView ()

@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *likeButton;

@end

@implementation HGPhotoCaptionView

-(void)setupCaption{
    self.userInteractionEnabled = YES;
    self.backgroundColor = RGBACOLOR(0, 0, 0, 179);
    self.frame = CGRectMake(0, 0, 320, 55);
    self.previousButton.frame = CGRectMake(2, 6, 60, 44);
    [self addSubview:self.previousButton];
    
    self.likeButton.frame = CGRectMake(124, 6, 72, 44);
    [self addSubview:self.likeButton];
    
    self.nextButton.frame = CGRectMake(257, 6, 60, 44);
    [self addSubview:self.nextButton];
}

- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(SCREEN_WIDTH, 55.f);
}

-(UIButton *)previousButton{
    if (_previousButton==nil) {
        _previousButton = [self buttonWithImage:@"BtnPreVious" hilightedImage:@"BtnPreViousPress"];
        _previousButton.tag = HGCAptionActionTypePrevious;
    }
    return _previousButton;
}

-(UIButton *)likeButton{
    if (_likeButton==nil) {
        _likeButton = [self buttonWithImage:@"BtnLike" hilightedImage:@"BtnLikePress"];
        _likeButton.tag = HGCAptionActionTypeLike;
    }
    return _likeButton;
}

-(UIButton *)nextButton{
    if (_nextButton==nil) {
        _nextButton= [self buttonWithImage:@"BtnNext" hilightedImage:@"BtnNextPress"];
        _nextButton.tag = HGCAptionActionTypeNext;
    }
    return _nextButton;
}

-(UIButton *)buttonWithImage:(NSString *)image hilightedImage:(NSString *)hilightedImage{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:hilightedImage] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(buttonCliked:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(IBAction)buttonCliked:(UIButton *)sender{
    if (self.actionBlock) {
        self.actionBlock(sender.tag);
    }
}
@end
