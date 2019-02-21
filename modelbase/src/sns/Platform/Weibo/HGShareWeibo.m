//
//  HGShareWeibo.m
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGShareWeibo.h"
#import "WeiboSDK.h"
#import "NSString+NXOAuth2.h"

NSString * const kWeiboNewsContentKey = @"WeiboContent";

@interface HGShareWeibo()<WeiboSDKDelegate>
@property (nonatomic, copy) NSString *rediretUri;
@end

@implementation HGShareWeibo

CREATE_SHARER_INSTANCE;

-(NSString *)accountType{
    return @"AccountTypeSinaWeibo";
}
-(void)registerWithKey:(NSString *)key secret:(NSString *)secret redirect:(NSString *)redirect{
    [WeiboSDK registerApp:key];
    
    self.rediretUri = redirect;
    
    NSURL *authorizationURL = [NSURL URLWithString:@"https://open.weibo.cn/oauth2/authorize"];
    NSURL *tokenURL = [NSURL URLWithString:@"https://open.weibo.cn/oauth2/access_token"];
    NSURL *redirectURL = [NSURL URLWithString:redirect];
    
    [[NXOAuth2AccountStore sharedStore] setClientID:key secret:secret authorizationURL:authorizationURL tokenURL:tokenURL redirectURL:redirectURL forAccountType:[self accountType]];
}
-(BOOL)canShare:(HGShareItem *)item{
    return item.itemType != HGShareItemTypeApp;
}

-(BOOL)isAuthorized{
    __block BOOL authorized = NO;
    NSArray *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self accountType]];
    [accounts enumerateObjectsUsingBlock:^(NXOAuth2Account *account, NSUInteger idx, BOOL *stop) {
        if ([account.accessToken hasExpired] == NO) {
            authorized = YES;
            *stop = YES;
        }
    }];
    return authorized;
}

-(BOOL)handleOpenURL:(NSURL *)url{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

-(void)requireAuthorizationWhitCallback:(HGShareKitCallback)callback{
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.rediretUri;
    
    if ([WeiboSDK isWeiboAppInstalled] && [WeiboSDK sendRequest:request]) {
        self.authorizationBlock = callback;
    }else{
        [super requireAuthorizationWhitCallback:callback];
    }
}


-(void)share:(HGShareItem *)item callback:(HGShareKitCallback)callback{
    //分享到微博
    void(^ShareBlock)(HGShareItem *item) = ^(HGShareItem *item){
        
        //定义处理返回结果的block
        void(^HandleResponseBlock)(NSData *responseData, NSError *error) = ^(NSData *responseData, NSError *error){
            if (error) {
                callback(NO,error);
            }else{
                NSError *jsonError;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
                    callback(NO,error);
                }else{
                    NSInteger errorCode = [dict[@"error_code"] integerValue];
                    NSString *errorMsg = dict[@"error"];
                    if (errorCode != 0) {
                        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorMsg.length>0? errorMsg : @"未知错误"};
                        NSError *error = [NSError errorWithDomain:@"HGShareKit" code:errorCode userInfo:userInfo];
                        callback(NO,error);
                    }else{
                        callback(YES,nil);
                    }
                }
            }
        };
        
        NSURL *url = [self shareUrlForItem:item];
        NSMutableDictionary *params = [[self paramsForItem:item] mutableCopy];
        
        NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self accountType]] firstObject];
        params[@"access_token"] = account.accessToken.accessToken;
        
        if (item.itemType==HGShareItemTypeImage) {
            [NXOAuth2Request performMethod:@"POST" onResource:url usingParameters:params withAccount:account sendProgressHandler:NULL responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                HandleResponseBlock(responseData,error);
            }];
        }else{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            NSString *bodyString = [NSString nxoauth2_stringWithEncodedQueryParameters:params];
            NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            
            NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
            [NSURLConnection sendAsynchronousRequest:request queue:currentQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                HandleResponseBlock(data,connectionError);
            }];
        }
    };
    
//    if ([self isAuthorized]) {
//        ShareBlock(item);
//    }else
    {
        [self requireAuthorizationWhitCallback:^(BOOL success, NSError *error) {
            if (success) {
                ShareBlock(item);
            }else{
                callback(success,error);
            }
        }];
    }
}

-(NSURL *)shareUrlForItem:(HGShareItem *)item{
    if (item.itemType==HGShareItemTypeImage && item.image!=nil) {
        return [NSURL URLWithString:@"https://upload.api.weibo.com/2/statuses/upload.json"];
    }
    return [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];
}
-(NSDictionary *)paramsForItem:(HGShareItem *)item{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"status"] = item.text;
    if (item.image ){
        if(item.itemType==HGShareItemTypeImage){
            params[@"pic"] = UIImageJPEGRepresentation(item.image, 0.7);
        }
        if(item.itemType == HGShareItemTypeNews){
            params[@"status"] = item.userInfo==nil ? item.text : [item.userInfo objectForKey:kWeiboNewsContentKey];
        }
    }
    return params;
}

#pragma mark WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    NSLog(@"didReceiveWeiboRequest");
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        if (response.statusCode==WeiboSDKResponseStatusCodeSuccess) {
            WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
            
            NXOAuth2AccessToken *oauthToken = [[NXOAuth2AccessToken alloc] initWithAccessToken:authResponse.accessToken refreshToken:nil expiresAt:authResponse.expirationDate];
            
            [self addAccountWithAccessToken:oauthToken];
        }else{
            NSError *error = [NSError errorWithDomain:@"微博授权错误" code:response.statusCode userInfo:nil];
            self.authorizationBlock(NO,error);
        }
        self.authorizationBlock = nil;
    }
}
@end

