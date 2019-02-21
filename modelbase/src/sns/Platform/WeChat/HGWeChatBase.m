//
//  HGWeChatBase.m
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGWeChatBase.h"
#import "NSString+NXOAuth2.h"

@interface HGWeChatBase ()<WXApiDelegate>

@property (nonatomic, copy) HGShareKitCallback callBack;

@end

@implementation HGWeChatBase

-(void)registerWithKey:(NSString *)key secret:(NSString *)secret redirect:(NSString *)redirect{
    [WXApi registerApp:key];
}
-(BOOL)canShare:(HGShareItem *)item{
    //未安装微信，则无法分享
    return [WXApi isWXAppInstalled];
}
-(BOOL)handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}
-(BOOL)isAuthorized{
    return YES;
}

-(void)requireAuthorizationWhitCallback:(HGShareKitCallback)callback{
    //do nothing.
}
-(void)share:(HGShareItem *)item callback:(HGShareKitCallback)callback{
    self.callBack = callback;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = self.scence;
    req.text = item.text;
    
    id messageObject = nil;
    switch (item.itemType) {
        case HGShareItemTypeNews:{
            WXWebpageObject *webObject = [WXWebpageObject object];
            webObject.webpageUrl = [item.URL absoluteString];
            messageObject = webObject;
        }
            break;
        case HGShareItemTypeImage:{
            WXImageObject *imgObject = [WXImageObject object];
            imgObject.imageData = UIImageJPEGRepresentation(item.image, 0.8);
            messageObject = imgObject;
        }
            break;
        case HGShareItemTypeApp:{
            WXAppExtendObject *appObject = [WXAppExtendObject object];
            appObject.extInfo =  [NSString nxoauth2_stringWithEncodedQueryParameters:item.userInfo];
            messageObject = appObject;
        }
            break;
        case HGShareItemTypeText:
            break;
        default:
            break;
    }
    
    if (item.itemType == HGShareItemTypeText) {
        req.bText = YES;
    }else{
        WXMediaMessage *mediaMessage = [WXMediaMessage message];
        mediaMessage.title = item.title;
        mediaMessage.description = item.text;
        if(item.image == nil){
            callback(NO,[NSError errorWithDomain:@"缩略图不存在" code:0 userInfo:nil]);
            return;
        }
        UIImage *thumImage = [UIImage imageNamed:@"IconShare-1"];
        mediaMessage.thumbData = UIImageJPEGRepresentation(thumImage, 0.6);
        //        [mediaMessage setThumbImage:item.image];
        mediaMessage.mediaObject = messageObject;
        req.message = mediaMessage;
        req.bText = NO;
    }
   BOOL result = [WXApi sendReq:req];
}


#pragma mark WXApiDelegate
-(void)onReq:(BaseReq *)req{
    DLog(@"called");
}
-(void)onResp:(BaseResp *)resp{
    if(!self.callBack){
        return;
    }
    if(resp.errCode == 0){
        self.callBack(YES,nil);
    }else{
        if(resp.errStr!=nil)
            self.callBack(NO,[NSError errorWithDomain:resp.errStr code:(int)resp.errCode userInfo:nil]);
        else
            self.callBack(NO,[NSError errorWithDomain:@"未知错误" code:resp.errCode userInfo:nil]);
    }
}


@end
