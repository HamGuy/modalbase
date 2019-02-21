//
//  HGShareViewController.m
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGShareViewController.h"
#import "HGPopContainerView.h"
#import "HGShareKit.h"
#import <JDStatusBarNotification/JDStatusBarNotification.h>

@interface HGShareViewController ()

@property (nonatomic, strong) HGShareItem *item;
@property (nonatomic, copy) HGShareActionCompletionBlock completionBlock;

@end

@implementation HGShareViewController

- (id)initWithShareItem:(HGShareItem *)item completion:(HGShareActionCompletionBlock)completionBlock;
{
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.item = item;
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)shrebuttonCliked:(UIButton *)sender{
//    [JDStatusBarNotification showWithStatus:@"分享成功" dismissAfter:2.4f styleName:JDStatusBarStyleSuccess];
//    if(self.completionBlock){
//        self.completionBlock();
//    }
//    return;
//    return;
   __block HGShareType sharetype = HGShareTypeSinaWeibo;
    switch (sender.tag) {
        case 0:
            sharetype = HGShareTypeSinaWeibo;
            break;
        case 1:
            sharetype = HGShareTypeWechatSession;
            break;
        case 2:
            sharetype = HGShareTypeWechatTimeline;
            break;
        default:
            break;
    }
    
    [HGPopContainerView dismiss];
    [[HGShareKit sharedInstance] share:self.item withType:sharetype callback:^(BOOL success, NSError *error) {
        if (success) {
            [JDStatusBarNotification showWithStatus:@"分享成功" dismissAfter:2.4f styleName:JDStatusBarStyleError];
        }else{
            if (sharetype != HGShareTypeSinaWeibo && (error.code == -2)) {
                [self failedWithMessageNotification:@"您取消了分享操作"];
                return;
            }
            [self failedWithMessageNotification:@"分享失败"];
        }
    }];
}

@end
