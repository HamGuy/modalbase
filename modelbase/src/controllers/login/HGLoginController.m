//
//  HGLoginController.m
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGLoginController.h"
#import "HGRegisterStepOneController.h"
#import "HGUserInfoService.h"
#import "MBProgressHUD.h"
#import "HGCurretUserContext.h"

@interface HGLoginController ()

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIView *containView;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) HGUserInfoService *userInfoService;

@end

@implementation HGLoginController

- (id)init
{
    self = [super initWithNibName:@"HGLoginController" bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"登录";
        self.userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addLeftBarButtonWithName:@"取消" withAction:@selector(close)];
    
//    [self addRightBarButtonWithName:@"TEST" withAction:@selector(test)];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.containView.layer.borderColor = [RGBCOLOR(251, 251, 251) CGColor];
    self.containView.layer.borderWidth = 0.5f;
    
    if (!is_iPhone5) {
        self.registerButton.top -= 64;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerdSuccessed:) name:kRegisterSuccessNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)dealloc
{
    [self.userInfoService cancelAllOperations];
    self.userInfoService = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)close{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShoudResetSelectIndexNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)test{
    [self.navigationController pushViewController:[AppDelegate userCenterController] animated:YES];
}

-(void)hideKeyboard{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

-(IBAction)login:(id)sender{
    [self hideKeyboard];
    if (self.usernameField.text.length >0 && self.passwordField.text.length>0) {
        [self loading];
        
        __weak typeof(self) mySelf = self;
        [self.userInfoService loginOperationWithUsername:self.usernameField.text Password:self.passwordField.text Successed:^(MKNetworkOperation *completedOperation, id result) {
            [mySelf successedWitnMessage:nil];
            NSDictionary *dict = result;
            HGCurretUserContext *context = [HGCurretUserContext sharedInstance];
            context.username = mySelf.usernameField.text;
            context.userId = [dict objectForKey:@"userid"];
            context.type = [dict objectForKey:@"type"];
            context.allowDownload = [[dict objectForKey:@"download"] isEqualToString:@"Y"];
            context.allowUpLoad = [[dict objectForKey:@"upload"] isEqualToString:@"Y"];
            context.allowEdit = [[dict objectForKey:@"edit"] isEqualToString:@"Y"];
            context.allowPreview = [[dict objectForKey:@"preview"] isEqualToString:@"Y"];
            context.allowPostAnnouces = [dict objectForKey:@"issue"] ? [[dict objectForKey:@"issue"] isEqualToString:@"Y"] :NO;
            mySelf.usernameField.text = nil;
            mySelf.passwordField.text = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil];
            [mySelf dismissViewControllerAnimated:YES completion:^{
                if (self.needSetCenterVc) {
                    [[AppDelegate centerController] setViewControllers:@[[AppDelegate userCenterController]]];
                    self.needSetCenterVc = NO;
                }
//                [mySelf.mm_drawerController setCenterViewController:[AppDelegate centerController]];
            }];
        } error:^(NSError *error) {
            mySelf.usernameField.text = nil;
            mySelf.passwordField.text = nil;
            [mySelf failedWithMessageNotification:@"登录失败，请稍后重试"];
        }];
    }
    else{
        [UIAlertView showNoticeWithTitle:nil message:@"用户或密码不能为空" cancelButtonTitle:@"确定"];
    }
}

-(void)registerdSuccessed:(NSNotification *)notification{
    if (notification.object) {
        NSArray *obj = notification.object;
        self.usernameField.text = obj[0];
        self.passwordField.text = obj[1];
    }
}

-(IBAction)registerAccount:(id)sender{
    HGRegisterStepOneController *controller = [[HGRegisterStepOneController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
