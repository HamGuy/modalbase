//
//  HGUserListControllerViewController.m
//  modelbase
//
//  Created by HamGuy on 7/4/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGUserListController.h"
#import "HGUserCell.h"
#import "HGUserInfoService.h"
#import "UserBrief.h"
#import "HGUserDeatilController.h"
#import "HGAdcancedSearchController.h"

@interface HGUserListController ()

@property (nonatomic, strong) UINib *userNib;
@property (nonatomic, strong) NSMutableArray*allUsers;
@property (nonatomic, strong) NSDictionary *condition;
@property (nonatomic, assign) NSInteger userType; //  0 模特 1 编辑 2 会员

@property (nonatomic, strong) HGUserInfoService *userInfoService;
@property (nonatomic, strong) UIViewController *leftViewController;

@end

@implementation HGUserListController

-(id)initWithSearchCondition:(NSDictionary *)condition userType:(NSInteger)type{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.condition = condition;
        self.userType = type;
        self.title = [self titeForType:type];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addbackButtonWithAction:@selector(goBack)];
    if(self.userType == 0){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 4, 72.f, 36.0f);
        [btn setTitle:@"高级搜索" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        btn.titleLabel.backgroundColor = [UIColor clearColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(wantAdavancedSearch) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advancedSearch:) name:KAdvacenedSearch object:nil];
    }
    
    self.numberOfSections = 1;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.layer.borderWidth = 0;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.endReached = YES;
    self.disablePull = YES;
    
    if (self.allUsers == nil) {
        self.allUsers = [@[] mutableCopy];
    }
    self.nextPage = 1;
    [self loadDatas:YES];

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

- (void)dealloc
{
    [self.userInfoService cancelAllOperations];
    self.userInfoService = nil;
}

#pragma mark - Getter
-(UINib *)userNib{
    if (_userNib == nil) {
        _userNib = [HGUserCell nib];
    }
    return _userNib;
}

-(HGUserInfoService *)userInfoService{
    if (_userInfoService == nil) {
        _userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _userInfoService;
}

#pragma mark - Private
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)wantAdavancedSearch{
    HGAdcancedSearchController *controller = [[HGAdcancedSearchController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)advancedSearch:(NSNotification *)notification{
    if (notification.userInfo) {
        self.condition = notification.userInfo;
        [self loadDatas:YES];
    }
}


-(NSString *)titeForType:(NSInteger)type{
    NSString *title = @"全部";
    switch (type) {
        case 0:
            title = @"模特";
            break;
        case 1:
            title = @"经纪人";
            break;
        case 2:
            title = @"会员";
            break;
        default:
            break;
    }
    return title;
}
#pragma mark - Override

-(void)loadDatas:(BOOL)isFirstPage{
    self.loading = YES;
    if(isFirstPage){
        [self.allUsers removeAllObjects];
        self.nextPage = 1;
    }
    [self loading];
    __weak typeof(self) mySelf = self;
    [self.userInfoService searchUserWithCondition:self.condition Successed:^(MKNetworkOperation *completedOperation, NSArray *result, NSInteger totalPage) {
        [mySelf successedWitnMessage:nil];
        mySelf.loading = NO;
        
        [mySelf.allUsers addObjectsFromArray:result];
        
        if (result.count>0) {
            mySelf.tableView.tableFooterView = nil;
            mySelf.nextPage++;
        }
        mySelf.endReached = mySelf.allUsers.count >= totalPage;
        
        if(mySelf.allUsers.count == 0)
        {
            mySelf.tableView.tableFooterView = [mySelf nilResultViewWithMessage:@"暂无相关搜索结果"];
        }
        [mySelf.tableView reloadData];
    } error:^(NSError *error) {
        mySelf.loading = NO;
        mySelf.endReached = YES;
        [self failedWithMessageNotification:(error.code == 4444)?[error domain ]: @"无法完成当前请求，请稍后重试！"];
        if (error.code == 4444) {
            mySelf.tableView.tableFooterView = [mySelf nilResultViewWithMessage:@"暂无相关搜索结果"];
        }
    }];
}

-(void)doRefresh{
    [self loadDatas:YES];
}

-(void)loadMore{
    if (self.endReached) {
        return;
    }
    [self loadDatas:NO];
}


#pragma mark - UITableView DataSource and Delegate
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == self.numberOfSections) {
        return [super  tableView:tableView numberOfRowsInSection:section];
    }
    return self.allUsers.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.numberOfSections) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return [HGUserCell cellHeight];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HGUserCell *cell = [HGUserCell cellForTableView:tableView fromNib:self.userNib];
    UserBrief *user = self.allUsers[indexPath.row];
    cell.usertype = self.userType;
    [cell setContent:user withIndexPath:indexPath];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserBrief *user = self.allUsers[indexPath.row];
    HGUserDeatilController *controller = [[HGUserDeatilController alloc] initWithUserInfo:user];
    [self.navigationController pushViewController:controller animated:YES];
    
    
}



@end
