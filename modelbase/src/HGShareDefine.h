//
//  HGShareDefine.h
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//


typedef NS_ENUM(NSInteger, HGShareItemType){
    HGShareItemTypeText = 0,
    HGShareItemTypeImage,
    HGShareItemTypeNews,
    HGShareItemTypeApp
};

typedef NS_ENUM(NSInteger,HGShareType){
    HGShareTypeSinaWeibo = 0,
    HGShareTypeWechatSession,
    HGShareTypeWechatTimeline
};

typedef NS_ENUM(NSInteger,HGShareCategory){
    HGShareCategoryService,
    HGShareCategoryAction
};

typedef NS_ENUM(NSInteger,HGShareState){
    HGShareStateStarted = 0,
    HGShareStateSuccessed,
    HGShareStateFailed,
    HGShareStateCanceled
};
