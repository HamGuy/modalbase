//
//  HGAblumDetailInfoController.h
//  modelbase
//
//  Created by HamGuy on 5/20/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGAblumListController.h"

@class Ablum;
@interface HGAblumDetailInfoController : UIViewController

/**
 *  初始化专辑列表
 *
 *  @param type  专辑类型
 *  @param ablum 专辑具体信息
 *
 */
-(id)initWithType:(AblumType)type ablum:(Ablum *)ablum;

/**
 *  初始化专辑列表
 *
 *  @param type 专辑类型
 *  @param aid  专辑ID
 *
 */
-(id)initWithType:(AblumType)type ablumId:(NSString *)aid;

@end
