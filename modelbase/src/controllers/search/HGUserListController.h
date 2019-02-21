//
//  HGUserListController.h
//  modelbase
//
//  Created by HamGuy on 7/4/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGBaseTableViewController.h"

@interface HGUserListController : HGBaseTableViewController

-(id)initWithSearchCondition:(NSDictionary *)condition userType:(NSInteger)type;

@end
