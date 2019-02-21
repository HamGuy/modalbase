//
//  HGAblumListController.h
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGBaseTableViewController.h"

typedef NS_ENUM(NSInteger, AblumType){
    AblumTypeNew,
    AblumTypeRec,
    AblumTypeVip,
    AblumTypeCop,
    AblumTypeSearch
};



@interface HGAblumListController : HGBaseTableViewController

-(id)initWithAblumType:(AblumType)type;

@end
