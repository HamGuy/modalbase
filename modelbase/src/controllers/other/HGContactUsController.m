//
//  HGContactUsController.m
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGContactUsController.h"
#import "HGContactusCell.h"
#import "HGFeedBackController.h"

@interface HGContactUsController ()<UITabBarDelegate,UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UINib *contactUsCellNib;

@end

@implementation HGContactUsController

- (id)init
{
    self = [super initWithNibName:@"HGContactUsController" bundle:nil];
    if (self) {
        self.title = @"联系我们";
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addMoreButton];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.scrollEnabled = !is_iPhone5;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = RGBCOLOR(234, 234, 234);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UINib *)contactUsCellNib{
    if(_contactUsCellNib==nil){
        _contactUsCellNib = [HGContactusCell nib];
    }
    return _contactUsCellNib;
}

#pragma mark - UITableView DataSource and Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [HGContactusCell cellHeight];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HGContactusCell *cell = [HGContactusCell cellForTableView:tableView fromNib:self.contactUsCellNib];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor whiteColor];
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"市场/商业合作";
            cell.contentLabel.text = @"021-62192136";
            break;
        case 1:
            cell.titleLabel.text = @"会员服务";
            cell.contentLabel.text = @"021-62192136";
            break;
            
//        case 2:
//            cell.titleLabel.text = @"会员服务2";
//            cell.contentLabel.text = @"13761798449";
//            break;
            
        case 2:
            cell.titleLabel.text = @"新浪微博";
            cell.contentLabel.text = @"模特基地2014";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 3:
            cell.titleLabel.text = @"腾讯微博";
            cell.contentLabel.text = @"http://t.qq.com/Model-base";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 4:
            cell.titleLabel.text = @"官方微信";
            cell.contentLabel.text = @"18117206632";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 5:
            cell.titleLabel.text = @"官方QQ";
            cell.contentLabel.text = @"2593795401";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 6:
            cell.titleLabel.text = @"用户反馈";
            cell.contentLabel.text = @"";
            cell.isAccessibilityElement = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopBar7"]];
            break;
            
            
        default:
            break;
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HGContactusCell *cell = (HGContactusCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.row <= 1){
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",cell.contentLabel.text]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        }else{
            [UIAlertView showNoticeWithTitle:@"提示" message:@"抱歉，您的设备不支持拨打电话功能" cancelButtonTitle:@"确定"];
        }

    }
    
    if(indexPath.row==6){
        HGFeedBackController *controller = [[HGFeedBackController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}



@end
