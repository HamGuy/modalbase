//
//  HGUserDeatilController.m
//  modelbase
//
//  Created by HamGuy on 7/4/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGUserDeatilController.h"
#import "HGUserInfoService.h"
#import "HGUserCenterController.h"
#import "UIImageView+Loading.h"
#import "UIImageView+Rounded.h"
#import "HGuserDetailCell.h"


@interface HGUserDeatilController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UserBrief *currentUserInfo;

//header
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *roleTypeView;

//footer
@property (nonatomic, strong) IBOutlet UIView *footerView;

@property (nonatomic, weak) IBOutlet UITableView *tableview;
@property (nonatomic, strong) HGUserInfoService *userInfoService;

@property (nonatomic, strong) UINib *detailNib;

@property (nonatomic, strong) NSMutableDictionary *userDetailDict;

@property (nonatomic, strong) UIViewController *leftViewController;

@property (nonatomic, strong) NSMutableArray *keyArray;
@property (nonatomic, strong) NSMutableArray *valueArray;

@end

@implementation HGUserDeatilController

- (id)initWithUserInfo:(UserBrief *)userInfo
{
    self = [super initWithNibName:@"HGUserDeatilController" bundle:nil];
    if (self) {
        // Custom initialization
        self.currentUserInfo = userInfo;
        self.title = @"个人资料";
        self.keyArray = [@[] mutableCopy];
        self.valueArray =[@[] mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addbackButtonWithAction:@selector(goBack)];
    
    self.tableview.tableHeaderView = self.headerView;
    self.tableview.tableFooterView = self.footerView;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.avatarView roundedWithBorderWidth:2.0 borderColor:[UIColor whiteColor]];
    
    self.nameLabel.text = self.currentUserInfo.name;
    NSString *avatarUrl = [NSString stringWithFormat:@"%@%@",kBaseImageUrl,self.currentUserInfo.head];
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"IConDefaultAvata"] options:SDWebImageRefreshCached];
    self.roleTypeView.image = [self imageForUserType:0];
    
    [self.keyArray addObject:@"个人简介"];
    [self.valueArray addObject:self.currentUserInfo.info ? : @""];
    
    [self askforUserDetailInfo];
    
    
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
    [self.userInfoService cancelAllOperations];
    self.userInfoService = nil;
}

#pragma mark - Getter
-(HGUserInfoService *)userInfoService{
    if (_userInfoService == nil) {
        _userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _userInfoService;
}

-(UINib *)detailNib{
    if (_detailNib == nil) {
        _detailNib = [HGuserDetailCell nib];
    }
    return _detailNib;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (is_iPhone5==NO && self.keyArray.count!=0) {
        [self.tableview reloadData];
    }

}

#pragma mark - Private
-(void)askforUserDetailInfo{
    [self loading];
    __weak typeof(self) mySelf = self;
    
    [self.userInfoService getUserDetail:self.currentUserInfo.userID Successed:^(MKNetworkOperation *completedOperation, id result) {
        [mySelf successedWitnMessage:nil];
        NSDictionary *dict = result;
        if (dict && dict.count>0) {
            [mySelf configData:result];
            [mySelf.tableview reloadData];
        }
    } error:^(NSError *error) {
        [mySelf failedWithMessage:@"获取个人资料失败，请稍候重试！" conmpleted:nil];
        mySelf.tableview.hidden =YES;
    }];
}

-(UIImage *)imageForUserType:(NSString *)type{
    if ([type isEqualToString:kUserTypeUser]) {
        return nil;
    }
    
    NSString *imgName = nil;
    if ([type isEqualToString:kUserTypeModel]) {
        imgName = @"IconModel";}
    else if ([type isEqualToString:kUserTypeEditor]) {
        imgName = @"Iconeditor";
    }else if([type isEqualToString:kUserTypeVIP]){
        imgName = @"IconVIP";
    }
    
    return [UIImage imageNamed:imgName];
}

-(void)configData:(NSDictionary *)dict{
    [self.keyArray addObject:@"真实姓名"] ;
    [self.valueArray addObject:dict[@"realname"]];
    if ([self.currentUserInfo.type isEqualToString:kUserTypeModel]) {
        [self.keyArray addObject:@"胸围"] ;
        [self.valueArray addObject:dict[@"chest"]];
        [self.keyArray addObject:@"腰围"] ;
        [self.valueArray addObject:dict[@"waistline"]];
        [self.keyArray addObject:@"臀围"] ;
        [self.valueArray addObject:dict[@"hipline"]];
        [self.keyArray addObject:@"身高"];
        [self.valueArray addObject:dict[@"height"]];
        [self.keyArray addObject:@"年龄"];
        [self.valueArray addObject:dict[@"age"]];
        [self.keyArray addObject:@"联系电话"];
        [self.valueArray addObject:dict[@"telephone"]];
        [self.keyArray addObject:@"微信"];
        [self.valueArray addObject:dict[@"weixin"]];
    }else if([self.currentUserInfo.type isEqualToString:kUserTypeEditor]){
        [self.keyArray addObject:@"类型"] ;
        [self.valueArray addObject:dict[@"type"]];
        [self.keyArray addObject:@"职务"] ;
        [self.valueArray addObject:dict[@"position"]];
        [self.keyArray addObject:@"电话"] ;
        [self.valueArray addObject:dict[@"telephone"]];
        [self.keyArray addObject:@"地址"] ;
        [self.valueArray addObject:dict[@"address"]];
        [self.keyArray addObject:@"简介"] ;
        [self.valueArray addObject:dict[@"description"]];
        [self.keyArray addObject:@"微信"] ;
        [self.valueArray addObject:dict[@"weixin"]];
    }else if([self.currentUserInfo.type isEqualToString:kUserTypeVIP]){
        [self.keyArray addObject:@"职务"] ;
        [self.valueArray addObject:dict[@"position"]];
        [self.keyArray addObject:@"电话"] ;
        [self.valueArray addObject:dict[@"telephone"]];
        [self.keyArray addObject:@"地址"] ;
        [self.valueArray addObject:dict[@"address"]];
        [self.keyArray addObject:@"简介"] ;
        [self.valueArray addObject:dict[@"description"]];
        [self.keyArray addObject:@"微信"] ;
        [self.valueArray addObject:dict[@"weixin"]];
    }
}


#pragma mark - UITableView DataSource and Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.keyArray.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [HGuserDetailCell cellHeight];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HGuserDetailCell *cell = [HGuserDetailCell cellForTableView:tableView fromNib:self.detailNib];
    NSInteger index = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setUpCellWithKey:self.keyArray[index] andValue:self.valueArray[index]];
    return cell;
}

#pragma mark - Action
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)gotoUserCenter:(id)sender{
    HGUserCenterController *controller = [[HGUserCenterController alloc] initWithUserName:self.currentUserInfo.name];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
