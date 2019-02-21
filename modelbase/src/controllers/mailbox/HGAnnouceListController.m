//
//  HGAnnouceListController.m
//  modelbase
//
//  Created by HamGuy on 7/3/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAnnouceListController.h"
#import "HGUserInfoService.h"
#import "HGMessageCell.h"
#import "AnnounceMent.h"
#import "HGPostAnnounceMnetController.h"
#import "HGAnnouceDetailController.h"
#import "UIViewController+Acess.h"

@interface HGAnnouceListController ()<UITextFieldDelegate>{
    NSInteger testCount;
}

@property (nonatomic, strong) UINib *messageNib;
@property (nonatomic, strong) HGUserInfoService *userInfoService;
@property (nonatomic, strong) NSArray *allAnnounces;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) NSArray *tmpList;
@property (nonatomic, strong) UIViewController *leftViewController;

@end

@implementation HGAnnouceListController

- (id)initWithAnnounceList:(NSArray *)list{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"通告列表";
        self.allAnnounces = list;
        self.tmpList = list;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self addbackButtonWithAction:@selector(goBack)];
//    [self addMoreButton];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [self searchView];
    //    self.tableView.separatorColor = [UIColor redColor];
    if([self canPostAnnouce]){
        [self addRightButtonWithImage:[UIImage imageNamed:@"IconAdd"] highlight:nil action:@selector(postAnnounce)];
    }
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRefresh) name:kRefresAnnouceNotification object:nil];
    
    self.numberOfSections = 0;    
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
        _searchField = [[UITextField alloc] initWithFrame:CGRectMake(40, 10, 250, 27)];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRefresAnnouceNotification object:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HGMessageCell *cell = [HGMessageCell cellForTableView:tableView fromNib:self.messageNib];
    
    if(indexPath.row == testCount){
        cell.seperatorView.width = SCREEN_WIDTH;
    }
    [cell setContent:self.allAnnounces[indexPath.row] withIndexPath:indexPath];
    
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allAnnounces.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [HGMessageCell cellHeight];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AnnounceMent *annoucement = [self.allAnnounces objectAtIndex:indexPath.row];
    HGAnnouceDetailController *controller = [[HGAnnouceDetailController alloc] initWithAnnouceMnet:annoucement];
    [self.navigationController pushViewController:controller animated:YES];
}


-(void)doRefresh{
    self.loading = YES;
    [self checkMessages];
}
//
//-(void)loadMore{
//    self.loading = NO;
//}

-(void)checkMessages{
    [self loading];
    
    __weak typeof(self) mySelf = self;
    [self.userInfoService getAnnounceListSuccessed:^(MKNetworkOperation *completedOperation, id result) {
        [mySelf successedWitnMessage:nil];
        NSArray *array = result;
        
        mySelf.loading = NO;
        if (array.count >0) {
            mySelf.tableView.tableFooterView = nil;
            mySelf.allAnnounces = array;
            mySelf.tmpList = array;
            [mySelf.tableView reloadData];
        }else{
            mySelf.tableView.tableFooterView = [self nilResultViewWithMessage:@"暂无通告"];
        }
    } error:^(NSError *error) {
        mySelf.loading = NO;
        [mySelf failedWithMessageNotification:@"加载通告列表失败，请稍候重试!"];
    }];
}

-(void)postAnnounce{
    HGPostAnnounceMnetController *controller = [[HGPostAnnounceMnetController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
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
        
        self.allAnnounces = [self.tmpList filteredArrayUsingPredicate:predicate];
        [self.tableView reloadData];
    }else{
        [self hideKeyboard];
        self.allAnnounces = self.tmpList;
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
