//
//  HGCurretUserContext.h
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserLogoutNotification @"userlogout"
#define kUserLogInSucceedNotification @"userlogin"

@interface HGCurretUserContext : NSObject

+(HGCurretUserContext *)sharedInstance;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, assign) BOOL allowEdit;
@property (nonatomic, assign) BOOL allowPreview;
@property (nonatomic, assign) BOOL allowUpLoad;
@property (nonatomic, assign) BOOL allowDownload;
@property (nonatomic, assign) BOOL allowPostAnnouces;

-(void)logout;

@end
