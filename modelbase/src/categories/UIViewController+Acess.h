//
//  UIViewController+Acess.h
//  modelbase
//
//  Created by HamGuy on 6/29/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Acess)

-(BOOL)canDownload;
-(BOOL)canUpload;
-(BOOL)canEdit;
-(BOOL)canPreview;
-(BOOL)canPostAnnouce;


-(BOOL)isLogined;

-(BOOL)wifiNetwork;
-(BOOL)isNetworkEnabled;

@end
