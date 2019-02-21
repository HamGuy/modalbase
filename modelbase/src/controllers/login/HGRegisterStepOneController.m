//
//  HGRegisterStepOneController.m
//  modelbase
//
//  Created by HamGuy on 5/21/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGRegisterStepOneController.h"
#import "HGRegisterStepTwoController.h"
#import "HGUserInfoService.h"
#import "MBProgressHUD.h"
#import "UIAlertView+Block.h"

@interface HGRegisterStepOneController ()

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *repeatPasswordField;

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong)  UIViewController *leftViewController;
@property (nonatomic, strong) HGUserInfoService *userService;

@end

@implementation HGRegisterStepOneController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"注册 Step One";
        self.userService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addbackButtonWithAction:@selector(goBack)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.containerView.layer.borderColor = [RGBCOLOR(251, 251, 251) CGColor];
    self.containerView.layer.borderWidth = 0.5f;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.leftViewController = self.mm_drawerController.leftDrawerViewController;
    [self.mm_drawerController setLeftDrawerViewController:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setLeftDrawerViewController:self.leftViewController];

}

-(void)dealloc{
    [self.userService cancelAllOperations];
    self.userService = nil;
}

#pragma mark - Actions
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideKeyboard{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.repeatPasswordField resignFirstResponder];

}

-(IBAction)registerAsMemberOnly:(id)sender{
    if ([self isValidateRegisterInfo]) {
        [self loading];
        
        __weak typeof(self) mySelf = self;
        [self.userService registerUserWithUsername:self.usernameField.text Code:self.repeatPasswordField.text Successed:^(MKNetworkOperation *completedOperation, id result) {
            //成功，没错
            [mySelf failedWithMessage:@"注册成功！" conmpleted:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kRegisterSuccessNotification object:@[mySelf.usernameField.text,mySelf.repeatPasswordField.text]];
                [mySelf.navigationController popViewControllerAnimated:YES];
            }];
             } error:^(NSError *error) {
                 NSString *errorMsg = @"注册失败，请稍后重试！";
                 if (error.code == -1) {
                     errorMsg = @"注册失败：用户名已存在！";
                 }
                 [mySelf failedWithMessage:errorMsg conmpleted:nil];
        }];
    }
}


#pragma mark - Private

-(BOOL)isValidateRegisterInfo{
    if( [self checkFieldIsNotEmpty:self.usernameField emptyMessage:@"用户名不能可为空"] && [self checkFieldIsNotEmpty:self.passwordField emptyMessage:@"密码不能可为空"] && [self checkFieldIsNotEmpty:self.repeatPasswordField emptyMessage:@"重复密码不能可为空"]){
        if ( [self.passwordField.text isEqualToString:self.repeatPasswordField.text]){
            return YES;
        }else{
            [UIAlertView showNoticeWithTitle:@"错误" message:@"两次输入密码不一致，请重新输入" cancelButtonTitle:@"确定"];
            self.passwordField.text = @"";
            self.repeatPasswordField.text=@"";
            [self.passwordField becomeFirstResponder];
        }
    }
    return NO;
}

- (BOOL) checkFieldIsNotEmpty:(UITextField *)field emptyMessage:(NSString *)message{
    NSString *fieldText = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([fieldText length] == 0) {
        
        [UIAlertView showNoticeWithTitle:@"错误" message:message cancelButtonTitle:@"确定"];
        [field becomeFirstResponder];
        
        return NO;
    }
    return YES;
}

@end
