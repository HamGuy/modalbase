//
//  HGLeftViewController.m
//  modelbase
//
//  Created by HamGuy on 5/15/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGLeftViewController.h"
#import "HGCurretUserContext.h"
#import "HGRegisterStepTwoController.h"

@interface HGLeftViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger currentSelectedIndex;
}
@property (nonatomic, weak) IBOutlet UITableView *settingTable;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) NSArray *datas;

@end

@implementation HGLeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(IS_IOS6()){
        self.headerView.height -= 20.f;
    }
    self.settingTable.tableHeaderView = self.headerView;
    self.settingTable.scrollEnabled=!is_iPhone5;
    self.settingTable.bounces = NO;
    _datas = [@[@"首页",@"个人中心",@"搜索",@"新片速递",@"推荐大师",@"合作专区",@"联系我们",@"收件箱"] copy];
    [self resetIndex];
    self.settingTable.backgroundColor = [UIColor clearColor];
    self.settingTable.backgroundView = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetIndex) name:kShoudResetSelectIndexNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShoudResetSelectIndexNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource and Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"leftSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    UIImageView *bgView =nil;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BgSideCellRed"]];
        cell.backgroundColor=[UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        if (IS_IOS6()) {
            cell.textLabel.backgroundColor = [UIColor grayColor];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
        
        bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BgSideCellWhite"]];
        bgView.frame = CGRectMake(0, 0, 320, 50);
        if(indexPath.row%2==0){
            cell.backgroundView = nil;
            cell.backgroundView = bgView;
        }
        
    }
    
    cell.textLabel.text = _datas[indexPath.row];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(currentSelectedIndex == indexPath.row)
        return;
    
    __block UIViewController *vc = nil;
    switch (indexPath.row) {
        case 0:
            vc = [AppDelegate homeViewController];
            break;
        case 1:
//            vc = ([HGCurretUserContext sharedInstance].username) ? [AppDelegate userCenterController]: [AppDelegate loginController];
            vc = [[HGRegisterStepTwoController alloc] initWithRegisterType:RegisterTypeEditor];
            break;
        case 2:
            vc = [AppDelegate searchController];
            break;
        case 3:
            vc = [AppDelegate newsAblumListController];
            break;
        case 4:
            vc = [AppDelegate recAblumListController];
            break;
//        case 5:
//            vc = [AppDelegate vipAblumListController];
//            break;
        case 5:
            vc = [AppDelegate copAblumListController];
            break;
        case 6:
            vc = [AppDelegate contactUsController];
            break;
        case 7:
            vc = [AppDelegate msgListController];
//        case 8:
//            vc = [AppDelegate loginController];
            break;
        default:
            break;
    }
    currentSelectedIndex= indexPath.row;
    
    if(vc!=nil){
        
        if((indexPath.row>=3 && indexPath.row<=5)){
            if(![[AppDelegate centerController].childViewControllers containsObject:vc])
                [[AppDelegate centerController] pushViewController:vc animated:YES];
        }else if(indexPath.row == 1)
        {
            if ([vc isKindOfClass:[HGLoginController class]]) {
                HGNavigationController *nav = [[HGNavigationController alloc] initWithRootViewController:vc];
                if ([vc isKindOfClass:[HGLoginController class]]) {
                    ((HGLoginController *)vc).needSetCenterVc = YES;
                }
                [[AppDelegate centerController] presentViewController:nav animated:YES completion:nil];
            }else{
                [[AppDelegate centerController] setViewControllers:@[vc] animated:NO];            }
        }else{
            [[AppDelegate centerController] setViewControllers:@[vc] animated:NO];
        }
        
        [self.mm_drawerController setCenterViewController:[AppDelegate centerController] withFullCloseAnimation:YES completion:nil];
    }
}


-(void)resetIndex{
    [self.settingTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    currentSelectedIndex = 0;
    if (![[[AppDelegate centerController].viewControllers objectAtIndex:0] isKindOfClass:[HGHomeViewController class]]) {
        [[AppDelegate centerController] setViewControllers:@[[AppDelegate homeViewController]] animated:YES];
    }
}

@end
