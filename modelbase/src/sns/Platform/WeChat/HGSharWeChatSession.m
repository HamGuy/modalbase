//
//  HGSharWeChatSession.m
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGSharWeChatSession.h"

@implementation HGSharWeChatSession


CREATE_SHARER_INSTANCE;

-(NSString *)accountType{
    return @"AccountTypeWeChatSession";
}

-(void) share:(HGShareItem *)item callback:(HGShareKitCallback)callback{
    self.scence = WXSceneSession ;
    [super share:item callback:callback];
}


@end
