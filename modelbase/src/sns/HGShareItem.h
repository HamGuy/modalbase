//
//  HGShareItem.h
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGShareDefine.h"

@interface HGShareItem : NSObject

@property (nonatomic, assign) HGShareItemType itemType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDictionary *userInfo;

@end
