//
//  HGPostAnnounceMnetController.m
//  modelbase
//
//  Created by HamGuy on 7/1/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGPostAnnounceMnetController.h"
#import "HGUserInfoService.h"
#import "UIAlertView+Block.h"

@interface HGPostAnnounceMnetController ()

@property (nonatomic, weak) IBOutlet UITextField *titleField;
@property (nonatomic, weak) IBOutlet UITextView *contentView;

@property (nonatomic, strong) HGUserInfoService *userInfoService;


@property (nonatomic, strong) UIViewController *leftViewController;
@end

@implementation HGPostAnnounceMnetController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"发通告";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addbackButtonWithAction:@selector(goback)];
    self.view.backgroundColor = RGBCOLOR(243, 243, 241);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
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

-(HGUserInfoService *)userInfoService{
    if (_userInfoService == nil) {
        _userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _userInfoService;
}

-(void)dealloc{
    [self.userInfoService cancelAllOperations];
    self.userInfoService = nil;
}

-(void)goback{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideKeyboard{
    [self.titleField resignFirstResponder];
    [self.contentView resignFirstResponder];
}

-(IBAction)sendAnnouncement:(id)sender{
    if (self.titleField.text.length == 0 || self.contentView.text.length==0) {
        [UIAlertView showNoticeWithTitle:@"提示" message:@"标题或内容不能为空！" cancelButtonTitle:@"确定"];
    }else{
        [self loading];
        
        NSDictionary *para = @{@"requesttype":@"tonggaosend",
                               @"title":self.titleField.text,
                               @"content":self.contentView.text};
        
        __weak typeof(self) mySelf = self;
        [self.userInfoService sendAnnouceMnet:para Successed:^(MKNetworkOperation *completedOperation, id result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefresAnnouceNotification object:nil userInfo:nil];
            [mySelf.navigationController popViewControllerAnimated:YES];
        } error:^(NSError *error) {
            [self failedWithMessage:@"发送通告失败！" conmpleted:nil];
        }];
    }
}
@end
