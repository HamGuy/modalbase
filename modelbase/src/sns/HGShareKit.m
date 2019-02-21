//
//  HGShareKitCore.m
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGShareKit.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "NXOAuth2.h"
#import "NXOAuth2Account+Private.h"
#import "HGShareWeibo.h"
#import "HGSharWeChatSession.h"
#import "HGShareWeChatTimeLine.h"

@interface HGShareKit ()

@property (nonatomic, copy) HGShareItemCallBack shareItemCallBack;
@property (nonatomic, copy) HGShareKitCallback dxkCallBack;
@property (nonatomic, strong) HGShare *recentSharer;

@end

@implementation HGShareKit

+(instancetype)sharedInstance{
    static HGShareKit *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super alloc] init];
    });
    return instance;
}


#pragma Register Service
-(void)registerSinaWeiboKey:(NSString *)key secret:(NSString *)secret redirect:(NSString *)redirect{
    [[HGShareWeibo sharedInstance] registerWithKey:key secret:secret redirect:redirect];
}

-(void)registerWechat:(NSString *)wechatKey{
    [[HGSharWeChatSession sharedInstance] registerWithKey:wechatKey secret:nil redirect:nil];
    [[HGShareWeChatTimeLine sharedInstance] registerWithKey:wechatKey secret:nil redirect:nil];
}


#pragma mark Authorization
-(BOOL)isAuthorized:(HGShareType)shareType{
    HGShare *sharer = [self sharerForType:shareType];
    return [sharer isAuthorized];
}
-(void)requireAuthorization:(HGShareType)shareType callback:(HGShareKitCallback)callback{
    if ([self isAuthorized:shareType]) {
        callback(YES,nil);
        return;
    }
    HGShare *sharer = [self sharerForType:shareType];
    
    NSString *accountType = [sharer accountType];
    if ([[NXOAuth2AccountStore sharedStore] configurationForAccountType:accountType] == nil) {
        callback(NO,[self errorWithCode:1]);
        return;
    };
    [sharer requireAuthorizationWhitCallback:callback];
}
#pragma mark Share
-(void)share:(HGShareItem *)item withType:(HGShareType)shareType callback:(HGShareKitCallback)callBack{
    HGShare *sharer = [self sharerForType:shareType];
    [self sharer:sharer withItem:item callback:callBack];
}

-(void)sharer:(HGShare *)sharer withItem:(HGShareItem *)item  callback:(HGShareKitCallback)callBack{
    __weak typeof(self) mySelf = self;
    mySelf.recentSharer = sharer;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if([sharer canShare:item]){
        [sharer share:item callback:^(BOOL success, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"error code is %d",error.code);
            if(mySelf.shareItemCallBack != nil){
                if(success){
                    mySelf.shareItemCallBack(sharer.shareType,item,HGShareStateSuccessed);
                }else{
                    //当跳转到微信或者QQ，如果没有完成分享操作（如点击‘取消’或者返回，errocode为-2或者-5,）
                    if(error.code ==-2 || error.code == -5){
                        mySelf.shareItemCallBack(sharer.shareType,item,HGShareStateCanceled);
                    }else {
                        mySelf.shareItemCallBack(sharer.shareType,item,HGShareStateFailed);
                    }
                }
            }else{
                callBack(success,error);
            }
        }];
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        callBack(NO,[NSError errorWithDomain:@"无法分享" code:-3 userInfo:nil]);
    }
}

-(BOOL)handleOpenURL:(NSURL *)url{
    BOOL didHandled = NO;
    if (self.recentSharer) {
        didHandled = [self.recentSharer handleOpenURL:url];
    }
    if(didHandled == NO){
        didHandled = [[HGSharWeChatSession sharedInstance] handleOpenURL:url];
    }
    if(didHandled == NO){
        didHandled = [[HGShareWeChatTimeLine sharedInstance] handleOpenURL:url];
    }
    if (didHandled == NO) {
        didHandled = [[HGShareWeibo sharedInstance] handleOpenURL:url];
    }
    return didHandled;
}


#pragma mark Private
-(HGShare *)sharerForType:(HGShareType)shareType{
    HGShare *sharer = nil;
    switch (shareType) {
        case HGShareTypeSinaWeibo:
            sharer = [HGShareWeibo sharedInstance];
            break;
        case HGShareTypeWechatSession:
            sharer = [HGSharWeChatSession sharedInstance];
            break;
        case HGShareTypeWechatTimeline:
            sharer = [HGShareWeChatTimeLine sharedInstance];
            break;
        default:
            break;
    }
    return sharer;
}

-(NSError *)errorWithCode:(NSInteger)errorCode{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"未知错误"};
    NSError *error = [NSError errorWithDomain:@"HGShareKit" code:errorCode userInfo:userInfo];
    return error;
}

-(UIViewController *)getRootViewController{
    UIViewController *rootviewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(rootviewController.presentedViewController!=nil)
        rootviewController = rootviewController.presentedViewController;
    return rootviewController;
}

@end
