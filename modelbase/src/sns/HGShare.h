//
//  HGShare.h
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"
#import "NXOAuth2Account+Private.h"
#import "HGShareItem.h"
#import "HGShareDefine.h"


extern NSString* const kWeiboNewsContentKey;

typedef void(^HGShareKitCallback)(BOOL success, NSError *error);

@protocol HGSharerProtocol <NSObject>

-(NSString *) iconName;
-(NSString *) title;

#pragma mark Share
-(BOOL)canShare:(HGShareItem *)item;
-(void)share:(HGShareItem *)item callback:(HGShareKitCallback)callback;

@end


#define ShareKit_IS_iPad() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define CREATE_SHARER_INSTANCE \
+(instancetype)sharedInstance{\
static id instance;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
instance = [[self alloc] init];\
[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(OAuthAccountDidChangeNotification:) name:NXOAuth2AccountStoreAccountsDidChangeNotification object:nil];\
[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(OAuthAccountDidFailToRequestAccessNotification:) name:NXOAuth2AccountStoreDidFailToRequestAccessNotification object:nil];\
});\
return instance;\
}\

@interface HGShare : NSObject<HGSharerProtocol>

@property (nonatomic, copy) HGShareKitCallback authorizationBlock;
@property (nonatomic, assign) HGShareType shareType;

+(instancetype)sharedInstance;

-(void)registerWithKey:(NSString *)key secret:(NSString *)secret redirect:(NSString *)redirect;
-(NSString *)accountType;
-(BOOL)isAuthorized;


-(BOOL)handleOpenURL:(NSURL *)url;

-(void)requireAuthorizationWhitCallback:(HGShareKitCallback)callback;



#pragma mark
-(void)addAccountWithAccessToken:(NXOAuth2AccessToken *)token;


#pragma mark NXOAuth Notification
-(void)OAuthAccountDidChangeNotification:(NSNotification *)notification;
-(void)OAuthAccountDidFailToRequestAccessNotification:(NSNotification *)notification;

@end
