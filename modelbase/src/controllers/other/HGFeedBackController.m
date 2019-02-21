//
//  HGFeedBackController.m
//  modelbase
//
//  Created by HamGuy on 5/18/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGFeedBackController.h"
#import "HGUserInfoService.h"
#import "MBProgressHUD.h"
#import <JDStatusBarNotification/JDStatusBarNotification.h>

@interface HGFeedBackController ()<UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *coninerView;
@property (nonatomic, weak) IBOutlet UITextView *feedbackTextView;
@property (nonatomic, strong) HGUserInfoService *userInfoService;

@end

@implementation HGFeedBackController

- (id)init
{
    self = [super initWithNibName:@"HGFeedBackController" bundle:nil];
    if (self) {
        self.title = @"用户反馈";
        self.userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self addbackButtonWithAction:nil];
    [self addRightBarButtonWithName:@"发送" withAction:@selector(sendFeedBack:)];
    
    _feedbackTextView.layer.borderColor = [RGBCOLOR(240, 240, 240) CGColor];
    _feedbackTextView.layer.borderWidth = 0.5f;
    _feedbackTextView.layer.cornerRadius = 5.f;
}

-(void)dealloc{
    [self.userInfoService cancelAllOperations];
    self.userInfoService = nil;
}

-(void)hideKeyboard{
    [self.feedbackTextView resignFirstResponder];
}

-(IBAction)sendFeedBack:(id)sender{
    [self hideKeyboard];
    if (self.feedbackTextView.text.length > 0) {
    
    [self loading];
        
    __weak typeof(self) mySelf = self;
    [self.userInfoService sendFeedback:self.feedbackTextView.text Successed:^(MKNetworkOperation *completedOperation, id result) {
        [mySelf successedWitnMessage:@"发送反馈信息成功"];
        [mySelf.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        [mySelf failedWithMessageNotification:@"发送反馈信息失败，请稍后重试！" ];
    }];
    }else{
        [UIAlertView showNoticeWithTitle:nil message:@"反馈内容不能为空！" cancelButtonTitle:@"确定"];
        [self.feedbackTextView becomeFirstResponder];
    }
}

@end
