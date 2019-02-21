//
//  HGOnePixelHeightView.m
//  modelbase
//
//  Created by HamGuy on 5/20/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGOnePixelHeightView.h"

static const NSInteger kHGOnePixelViewMoveUp = 1;//Default 0, move down


@implementation HGOnePixelHeightView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.height == 0.5) {
        return;
    }
    
    if (self.height < 0.5) {
        self.height = 0.5f;
    }else {
        CGFloat offset = self.height - 0.5;
        self.top= self.tag == kHGOnePixelViewMoveUp ? self.top : self.top + offset;
        self.height = 0.5f;
    }
}


@end
