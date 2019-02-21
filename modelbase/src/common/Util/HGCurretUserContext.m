//
//  HGCurretUserContext.m
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGCurretUserContext.h"
#import "HGDefaultHelper.h"

#define kUserNameKey @"userNameKey"
#define kUserTypeKey @"userTypeKey"
#define kUserIDKey @"userIDKey"
#define kUserAllowPreviewKey @"userAllowPreviewKey"
#define kUserAllowEditKey @"userAllowEditKey"
#define kUserAllowUploadKey @"userAllowUploadKey"
#define kUserAllowDownloadKey @"userAllowDownloadKey"
#define kUSerAllowPostAnnouce @"userAllowAnnounce"

static HGCurretUserContext *instance = nil;

@implementation HGCurretUserContext
@synthesize username=_username;
@synthesize type=_type;
@synthesize userId=_userId;
@synthesize allowDownload=_allowDownload;
@synthesize allowEdit =_allowEdit;
@synthesize allowPreview=_allowPreview;
@synthesize allowUpLoad=_allowUpLoad;
@synthesize allowPostAnnouces= _allowPostAnnouces;

+(HGCurretUserContext *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super alloc] init];
    });
    return instance;
}

-(void)logout{
    self.userId = nil;
    self.username = nil;
    self.type = nil;
    self.allowDownload = NO;
    self.allowEdit = NO;
    self.allowPostAnnouces =NO;
    self.allowPreview = NO;
    self.allowUpLoad = NO;
}

-(void)setUsername:(NSString *)username{
    _username = username;
    [HGDefaultHelper setObject:username forKey:kUserNameKey];
}

-(NSString *)username{
    return _username ? : [HGDefaultHelper objectForKey:kUserNameKey];
}

-(void)setType:(NSString *)type{
    _type = type;
    [HGDefaultHelper setObject:type forKey:kUserTypeKey];
}

-(NSString *)type{
    return _type ? : [HGDefaultHelper objectForKey:kUserTypeKey];
}

-(void)setUserId:(NSString *)userId{
    _userId = userId;
    [HGDefaultHelper setObject:userId forKey:kUserIDKey];
}

-(NSString *)userId{
    return _userId ? :[HGDefaultHelper objectForKey:kUserIDKey];
}

-(void)setAllowEdit:(BOOL)allowEdit{
    _allowEdit = allowEdit;
    [HGDefaultHelper setObject:[NSNumber numberWithBool:allowEdit] forKey:kUserAllowEditKey];
}

-(BOOL)allowEdit{
    NSNumber *number = [HGDefaultHelper objectForKey:kUserAllowEditKey];
    return number ? [number boolValue] : NO;
}

-(void)setAllowPreview:(BOOL)allowPreview{
    _allowPreview = allowPreview;
    [HGDefaultHelper setObject:[NSNumber numberWithBool:allowPreview] forKey:kUserAllowPreviewKey];
}

-(BOOL)allowPreview{
    NSNumber *number = [HGDefaultHelper objectForKey:kUserAllowPreviewKey];
    return number ? [number boolValue] : NO;
}

-(void)setAllowUpLoad:(BOOL)allowUpLoad{
    _allowUpLoad = allowUpLoad;
    [HGDefaultHelper setObject:[NSNumber numberWithBool:allowUpLoad] forKey:kUserAllowUploadKey];
}

-(BOOL)allowUpLoad{
    NSNumber *number = [HGDefaultHelper objectForKey:kUserAllowUploadKey];
    return number ? [number boolValue] : NO;
}

-(void)setAllowDownload:(BOOL)allowDownload{
    _allowDownload = allowDownload;
    [HGDefaultHelper setObject:[NSNumber numberWithBool:allowDownload] forKey:kUserAllowDownloadKey];
}

-(BOOL)allowDownload{
    NSNumber *number = [HGDefaultHelper objectForKey:kUserAllowDownloadKey];
    return number ? [number boolValue] : NO;
}

-(void)setAllowPostAnnouces:(BOOL)allowPostAnnouces{
    _allowPostAnnouces = allowPostAnnouces;
    [HGDefaultHelper setObject:[NSNumber numberWithBool:allowPostAnnouces] forKey:kUSerAllowPostAnnouce];
}

-(BOOL)allowPostAnnouces{
    NSNumber *number = [HGDefaultHelper objectForKey:kUSerAllowPostAnnouce];
    return number ? [number boolValue] : NO;
}
@end
