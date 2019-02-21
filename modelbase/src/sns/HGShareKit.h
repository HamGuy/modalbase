//
//  HGShareKi.h
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGShareDefine.h"
#import "HGShareItem.h"
#import "HGShare.h"


typedef void(^HGShareItemCallBack)(HGShareType shareType, HGShareItem *item, HGShareState state);


@interface HGShareKit : NSObject

+(instancetype)sharedInstance;

#pragma mark Register
-(void)registerSinaWeiboKey:(NSString *)key secret:(NSString *)secret redirect:(NSString *)redirect;
-(void)registerWechat:(NSString *)wechatKey;

#pragma mark Authorization
-(BOOL)isAuthorized:(HGShareType)shareType;
-(void)requireAuthorization:(HGShareType)shareType callback:(HGShareKitCallback)callback;

#pragma mark Share

-(void)share:(HGShareItem *)item withType:(HGShareType)shareType callback:(HGShareKitCallback)callBack;


#pragma mark Other
-(BOOL)handleOpenURL:(NSURL *)url;
@end
