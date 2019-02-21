//
//  HGShare.m
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGShare.h"
#import "HGPopContainerView.h"

@interface HGShare()<UIWebViewDelegate>
@end

@implementation HGShare

+(instancetype)sharedInstance{
    return nil;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)registerWithKey:(NSString *)key secret:(NSString *)secret redirect:(NSString *)redirect{
}
-(BOOL)canShare:(HGShareItem *)item{
    return NO;
}


-(NSString *)accountType{
    NSAssert(YES, @"subclass must overwrite this method");
    return nil;
}
-(BOOL)isAuthorized{
    return NO;
}
-(BOOL)handleOpenURL:(NSURL *)url{
    return NO;
}



-(void)requireAuthorizationWhitCallback:(HGShareKitCallback)callback{
    self.authorizationBlock = callback;
    
    NXOAuth2AccountStore *accountStore = [NXOAuth2AccountStore sharedStore];
    NSString *accountType = [self accountType];
    
    __weak typeof(self) myself = self;
    [accountStore requestAccessToAccountWithType:accountType withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        CGSize size = [UIScreen mainScreen].bounds.size;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, size.width-20, size.height-80)];
        
        webView.delegate = myself;
        [HGPopContainerView showWithView:webView animtionDuration:0.5f TapToDismiss:YES animationStyle:HGPopContainerAnimationStyleScaleFade completion:nil];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:preparedURL];
        request.HTTPShouldHandleCookies = NO;
        request.cachePolicy = NSURLCacheStorageNotAllowed;
        
        [webView loadRequest:request];
    }];
}

#pragma mark SharerDelgate
-(HGShareCategory)shareCategory{
    return HGShareCategoryService;
}

-(NSString *) iconName{
    return nil;
}

-(NSString *) title{
    return nil;
}

-(void)share:(HGShareItem *)item callback:(HGShareKitCallback)callback{
    NSAssert(NO, @"subclass must overwrite this method");
}

-(void)addAccountWithAccessToken:(NXOAuth2AccessToken *)token{
    NSString *accountType = [self accountType];
    
    NXOAuth2AccountStore *accountStore = [NXOAuth2AccountStore sharedStore];
    NSArray *oldAccounts = [accountStore accountsWithAccountType:accountType];
    [oldAccounts enumerateObjectsUsingBlock:^(NXOAuth2Account *account, NSUInteger idx, BOOL *stop) {
        [accountStore removeAccount:account];
    }];
    NXOAuth2Account *account = [[NXOAuth2Account alloc] initAccountWithAccessToken:token accountType:accountType];
    
    [accountStore addAccount:account];
}

#pragma mark UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([[NXOAuth2AccountStore sharedStore] handleRedirectURL:request.URL]) {
        return NO;
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *javaFormatString = @"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ";
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:javaFormatString, (int)webView.frame.size.width]];
}

#pragma mark NXOAuth Notification
-(void)OAuthAccountDidChangeNotification:(NSNotification *)notification{
    NXOAuth2Account *account = notification.userInfo[NXOAuth2AccountStoreNewAccountUserInfoKey];
    if (account && [account.accountType isEqualToString:self.accountType]) {
        self.authorizationBlock(YES,nil);
        [HGPopContainerView dismiss];
        self.authorizationBlock = nil;
    }
}
-(void)OAuthAccountDidFailToRequestAccessNotification:(NSNotification *)notification{
    NSError *error = [notification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
    self.authorizationBlock(NO,error);
    [HGPopContainerView dismiss];
    self.authorizationBlock = nil;
}

@end
