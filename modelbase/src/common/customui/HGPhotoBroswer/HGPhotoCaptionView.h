//
//  HGPhotoCaptionView.h
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "MWCaptionView.h"

typedef NS_ENUM(NSUInteger, HGCaptionActionType) {
    HGCAptionActionTypePrevious = 0,
    HGCAptionActionTypeLike,
    HGCAptionActionTypeNext
};

typedef void(^HGCaptionActionBlock)(HGCaptionActionType type);

@interface HGPhotoCaptionView : MWCaptionView

@property (nonatomic, copy) HGCaptionActionBlock actionBlock;

@end
