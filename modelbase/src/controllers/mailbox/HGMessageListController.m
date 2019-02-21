//
//  HGMessageListController.m
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGMessageListController.h"
#import "HGMessageCell.h"
#import "UIAlertView+Block.h"
#import "HGUserInfoService.h"
#import "HGMessage.h"
#import "MBProgressHUD.h"

@interface HGMessageListController ()<UITextFieldDelegate>{
    NSInteger testCount;
}

@property (nonatomic, strong) UINib *messageNib;
@property (nonatomic, strong) HGUserInfoService *userInfoService;
@property (nonatomic, strong) NSMutableArray *allMessages;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) NSArray *tmpList;

@end

@implementation HGMessageListController

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"收件箱";
        
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
//    [self addbackButtonWithAction:@selector(goBack)];
    [self addMoreButton];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [self searchView];
    //    self.tableView.separatorColor = [UIColor redColor];

    self.numberOfSections = 0;
    self.allMessages = [[HGMessage getAllMessages] mutableCopy];
    if(self.allMessages == nil){
        self.allMessages = [@[] mutableCopy];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self doRefresh];
}

-(UINib *)messageNib{
    if (_messageNib == nil) {
        _messageNib = [HGMessageCell nib];
    }
    return _messageNib;
}

-(HGUserInfoService *)userInfoService{
    if (_userInfoService == nil) {
        _userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _userInfoService;
}

-(UITextField *)searchField{
    if (_searchField == nil) {
        _searchField = [[UITextField alloc] initWithFrame:CGRectMake(40, 6, 250, 27)];
        _searchField.delegate = self;
        _searchField.borderStyle = UITextBorderStyleNone;
        _searchField.placeholder = @"请输入关键词查询";
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.font = [UIFont systemFontOfSize:14.f];
        _searchField.textColor = RGBCOLOR(102, 102, 102);
    }
    return _searchField;
}

-(void)dealloc{
    [self.userInfoService cancelAllOperations];
    self.userInfoService = nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HGMessageCell *cell = [HGMessageCell cellForTableView:tableView fromNib:self.messageNib];
    
    if(indexPath.row == testCount){
        cell.seperatorView.width = SCREEN_WIDTH;
    }
    [cell setContent:self.allMessages[indexPath.row] withIndexPath:indexPath];
    
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allMessages.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [HGMessageCell cellHeight];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HGMessage *msg = self.allMessages[indexPath.row];
    [UIAlertView showNoticeWithTitle:msg.sender message:msg.content cancelButtonTitle:@"确定"];
}


-(void)doRefresh{
    self.loading = YES;
    [self.allMessages removeAllObjects];
    [self checkMessages];
}

-(void)loadMore{
    self.loading = NO;
}

-(void)checkMessages{
    [self loading];
    
    __weak typeof(self) mySelf = self;
    [self.userInfoService getMessagesSuccessed:^(MKNetworkOperation *completedOperation, id result) {
        [mySelf successedWitnMessage:nil];
        NSArray *array = result;
        
        mySelf.loading = NO;
        if (array.count >0) {
            mySelf.tableView.tableFooterView = nil;
            mySelf.allMessages = [array mutableCopy];
            mySelf.tmpList = array;
            [mySelf.tableView reloadData];
        }else{
            mySelf.tableView.tableFooterView = [self nilResultViewWithMessage:@"暂无消息"];
        }
    } error:^(NSError *error) {
        mySelf.loading = NO;
        [mySelf failedWithMessageNotification:@"加载消息列表失败，请稍候重试!"];
    }];
}

-(void)loadMessages{
    
}


-(void)goBack{
    if (self.mm_drawerController.openSide==MMDrawerSideLeft) {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShoudResetSelectIndexNotification object:nil];
    }
}

-(UIView *)searchView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36.f)];
    view.backgroundColor = kCommonHoghtedColor;
    
    UIImageView *imgVIew = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 300, 27)];
    imgVIew.image = [UIImage imageNamed:@"BgSearch"];
    [view addSubview:imgVIew];
    
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 13, 13)];
    searchIcon.image = [UIImage imageNamed:@"IconSearch"];
    [view addSubview:searchIcon];
    
    [view addSubview:self.searchField];
    
    return view;
}

#pragma mark - UITextfiled delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length>0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS %@ OR content CONTAINS %@",textField.text,textField.text];
        
        self.allMessages = [self.tmpList filteredArrayUsingPredicate:predicate];
        [self.tableView reloadData];
    }else{
        [self hideKeyboard];
        self.allMessages = self.tmpList;
        [self.tableView reloadData];
    }
    return YES;
}

-(void)hideKeyboard{
    [self.searchField resignFirstResponder];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideKeyboard];
}
@end

