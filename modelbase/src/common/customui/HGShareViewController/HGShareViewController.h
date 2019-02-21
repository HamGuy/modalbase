//
//  HGShareViewController.h
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HGShareActionCompletionBlock)();

@class HGShareItem;

@interface HGShareViewController : UIViewController

- (id)initWithShareItem:(HGShareItem *)item completion:(HGShareActionCompletionBlock)completionBlock;


@end
