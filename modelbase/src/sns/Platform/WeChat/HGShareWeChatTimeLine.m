//
//  HGShareWeChatTimeLine.m
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGShareWeChatTimeLine.h"

@implementation HGShareWeChatTimeLine

CREATE_SHARER_INSTANCE;

-(BOOL)canShare:(HGShareItem *)item{
    //未安装微信，则无法分享
    return [WXApi isWXAppInstalled];
}

-(NSString *)accountType{
    return @"AccountTypeWeChatTimeLine";
}

-(void) share:(HGShareItem *)item callback:(HGShareKitCallback)callback{
    self.scence = WXSceneTimeline;
    [super share:item callback:callback];
}


@end
