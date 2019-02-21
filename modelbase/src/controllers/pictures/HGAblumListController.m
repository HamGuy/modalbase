//
//  HGAblumListController.m
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumListController.h"
#import "HGAblumInfoCell.h"
#import "HGAblumDetailInfoController.h"
#import "HGPhotoBroswerController.h"
#import "HGPhoto.h"
#import "HGShareViewController.h"
#import "HGPopContainerView.h"
#import "MBProgressHUD.h"
#import "Ablum.h"
#import "HGAblumService.h"
#import "PopoverView.h"
#import "HGOnePixelHeightView.h"
#import "HGShareItem.h"
#import "HGSandboxHelper.h"
#import "HGLocalAblumsManager.h"
#import "UIViewController+Acess.h"

@interface HGAblumListController ()<HGAblumInfoCellDelegate,MWPhotoBrowserDelegate>

@property (nonatomic, assign) AblumType ablumType;

@property (nonatomic, strong) UINib *ablumInfoCellNib;
@property (nonatomic, strong) NSMutableArray *allAblums;
@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) PopoverView *popOverView;
@property (nonatomic, strong) HGAblumService *ablumService;
@property (nonatomic, strong) UIView *popView;
@property (nonatomic, strong) NSString *currentId;
@property (nonatomic, assign) NSInteger nextPage;
@property (nonatomic, assign) NSInteger selectedIndex;


@property (nonatomic, strong) HGShareViewController *shareViewController;

@end

@implementation HGAblumListController

-(id)initWithAblumType:(AblumType)type{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self){
        switch (type) {
            case AblumTypeNew:
                self.title = @"新片速递";
                break;
            case AblumTypeRec:
                self.title = @"推荐大师";
                break;
            case AblumTypeVip:
                self.title = @"实力会员";
                break;
            case AblumTypeCop:
                self.title = @"合作专区";
                break;
                
            default:
                break;
        }
        self.ablumType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addbackButtonWithAction:@selector(goBack)];
    [self addRightButtonWithImage:[UIImage imageNamed:@"IconSort"] highlight:[UIImage imageNamed:@"IconSortSel"] action:@selector(showSortSelectorView)];
    self.numberOfSections = 1;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.layer.borderWidth = 0;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.endReached = YES;
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    //    self.tableView.backgroundColor = RGBCOLOR(234, 234, 234);
    
    //    self.allAblums = [[Ablum getAblumListWithDatatype:[self currentTypeName]] mutableCopy];
    if (self.allAblums == nil) {
        self.allAblums = [@[] mutableCopy];
    }
    self.numberOfSections = 1;
    [self loadDatas:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.selectedIndex = 0;
    [((HGNavigationController *)self.navigationController) setNavigationBarStyle:HGNavigationBarStyleDefault];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}


-(HGAblumService *)ablumService{
    if (_ablumService == nil) {
        _ablumService  = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _ablumService;
}
#pragma mark - Private

-(void)loadDatas:(BOOL)isFirstPage{
    self.loading = YES;
    if(isFirstPage){
        [self.allAblums removeAllObjects];
        self.nextPage = 1;
    }
    
    __weak typeof(self) mySelf = self;
    
    [self.ablumService getAblumListWithAblumType:[self currentTypeName] atPage:self.nextPage Successed:^(MKNetworkOperation *completedOperation, NSArray *result, NSInteger totalPage) {
        [mySelf successedWitnMessage:nil];
        mySelf.loading = NO;
        
        [mySelf.allAblums addObjectsFromArray:result];
        
        if (result.count>0) {
            mySelf.tableView.tableFooterView = nil;
            mySelf.nextPage++;
        }
        mySelf.endReached = mySelf.allAblums.count >= totalPage;
        
        if(mySelf.allAblums.count == 0)
        {
            mySelf.tableView.tableFooterView = [mySelf nilResultViewWithMessage:@"暂无相关专辑"];
        }
        [mySelf.tableView reloadData];
    } error:^(NSError *error) {
        mySelf.loading = NO;
        mySelf.endReached = YES;
        [mySelf failedWithMessageNotification:@"获取专辑列表失败！"];
    }];
}


-(NSString *)currentTypeName{
    NSString *name = nil;
    switch (self.ablumType)
    {   case AblumTypeNew:
            name = @"new";
            break;
        case AblumTypeRec:
            name = @"master";
            break;
        case AblumTypeVip:
            name = @"vip";
            break;
        case AblumTypeCop:
            name = @"cooper";
            break;
            
        default:
            break;
    }
    return name;
}


-(UINib *)ablumInfoCellNib{
    if(_ablumInfoCellNib==nil){
        _ablumInfoCellNib = [HGAblumInfoCell nib];
    }
    return _ablumInfoCellNib;
}

-(void)showSortSelectorView{
    CGPoint point = CGPointMake(SCREEN_WIDTH, 56.f);
    self.popOverView = [PopoverView showPopoverAtPoint:point inView:[UIApplication sharedApplication].keyWindow withViewArray:@[self.popView] delegate:nil];
}

-(void)goBack{
    if (self.mm_drawerController.openSide==MMDrawerSideLeft) {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShoudResetSelectIndexNotification object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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
    return self.allAblums.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.numberOfSections) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return [HGAblumInfoCell cellHeight];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.numberOfSections == indexPath.section && !self.endReached) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    HGAblumInfoCell *cell = [HGAblumInfoCell cellForTableView:tableView fromNib:self.ablumInfoCellNib];
    cell.delegate = self;
    if (self.allAblums.count>0) {
        Ablum *ablum = [self.allAblums objectAtIndex:indexPath.row];
        [cell setContent:ablum withIndexPath:indexPath];
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Ablum *ablum = _allAblums[indexPath.row];
    
    HGAblumDetailInfoController *detailController = [[HGAblumDetailInfoController alloc] initWithType:self.ablumType ablum:ablum];
    [self.navigationController pushViewController:detailController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - HGAblumInfoCell Delegate
-(void)ablumInfoCell:(HGAblumInfoCell *)cell didClickeButton:(UIButton *)btn{
    
    if ([btn.titleLabel.text isEqualToString:@"立刻阅读"]) {
        Ablum *ablum = self.allAblums[btn.tag];
        self.currentId = ablum.ablumid;//@"1123456789";
        __block MWPhoto *photo = nil;
        self.photos = [NSMutableArray array];
        
        NSArray *allPics = [[HGLocalAblumsManager sharedInstance] allPicsOfAblum:self.currentId];
        __block NSURL *url = nil;
        __weak typeof(self) mySelf = self;
        
        if (allPics ) {
            for (NSString *strUrl in allPics) {
                NSString *str = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:strUrl];
                url = [NSURL fileURLWithPath:str];
                photo =[MWPhoto photoWithURL:url];
                [mySelf.photos addObject:photo];
            }
        }
        self.selectedIndex = btn.tag;
        
        HGPhotoBroswerController *controller = [[HGPhotoBroswerController alloc] initWithDelegate:self];
        controller.enableGrid = NO;
        controller.enableSwipeToDismiss = YES;
        controller.zoomPhotosToFill = YES;
        controller.displayNavArrows = YES;
        controller.displayActionButton = NO;
        controller.alwaysShowControls = NO;
        controller.displaySelectionButtons = NO;
        if (IS_IOS6()) {
            controller.wantsFullScreenLayout = YES;
        }
        controller.startOnGrid = NO;
        [controller setCurrentPhotoIndex:0];
        [controller updateLikeButtonStatus:ablum.goodme == 0 ? YES : NO];
        
        [self.navigationController pushViewController:controller animated:YES];
        
        
    }else{
        if (![self canDownload]) {
            cell.indicatorContainerView.hidden = YES;
            return;
        }
        
        @autoreleasepool {
            
            __block Ablum *ablum = [self.allAblums objectAtIndex:btn.tag];
            __block HGAblumInfoCell *blockCell = cell;
            __weak typeof(self) mySelf = self;
            NSString *pathToStore = [[[HGSandboxHelper sharedInstance] getAppTmpDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"ablum%@.zip",ablum.ablumid]];
            
            __weak UIButton *blockBtn = btn;
            //开始下载
            [self.ablumService downloadAblumWithId:ablum.ablumid toFile:pathToStore progress:^(double progress) {
                [blockCell.downloadIndicator setProgress:progress animated:YES];
            } Successed:^(MKNetworkOperation *completedOperation, id result) {
                DLog(@"download success");
                //下载成功后，先保存下载的专辑id到已下载的礼拜里
                [[HGLocalAblumsManager sharedInstance] addDownloadedAblum:ablum.ablumid];
                //解压
                [[HGLocalAblumsManager sharedInstance] unZipAblum:ablum.ablumid fromTmpFilePath:result];
                //保存专辑缩略图到本地
                NSData *data = UIImageJPEGRepresentation(blockCell.coverImgView.image, 1.0);
                [[HGLocalAblumsManager sharedInstance] addCoverImage:data forAblum:ablum.ablumid];
                
                blockCell.downloadIndicator.progress = 1;
                [UIView animateWithDuration:0.2 animations:^{
                    blockCell.indicatorContainerView.hidden = YES;
                } completion:^(BOOL finished) {
                    //改变按钮文本并刷新当前cell
                    [blockBtn setTitle:@"立刻阅读" forState:UIControlStateNormal];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:blockBtn.tag inSection:0];
                    [mySelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
                [mySelf successedWitnMessage:nil];
            } error:^(NSError *error) {
                [mySelf failedWithMessage:@"下载专辑失败：请求超时，请稍后重试！" conmpleted:nil];
                 blockCell.indicatorContainerView.hidden = YES;
            }];
        }
    }
}

#pragma mark - MWPhotoBroswer Dalegate

-(NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return _photos.count;
}

-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    if (index<_photos.count) {
        return [_photos objectAtIndex:index];
    }
    return nil;
}

-(NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index{
    return [NSString stringWithFormat:@"%lu/%lu",(unsigned long)index+1,(unsigned long)_photos.count];
}

-(void)didClickLikeButton:(MWPhotoBrowser *)photoBrowser{
    [photoBrowser loading];
    __block HGAblumService *service = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    __block MWPhotoBrowser *blockBrowser = photoBrowser;
    __block Ablum *currentAblum = self.allAblums[self.selectedIndex];
    __block BOOL shouldLike = currentAblum.goodme == 0 ? YES : NO;
    [service postLikeWithBookId:self.currentId isLike:shouldLike Successed:^(MKNetworkOperation *completedOperation, id result) {
        service=nil;
        [blockBrowser successedWitnMessage:shouldLike ? @"点赞成功":@"取消点赞成功"];
        [blockBrowser updateLikeButtonStatus:!shouldLike];
        currentAblum.goodme = shouldLike ? 1 : 0;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } error:^(NSError *error) {
        service = nil;
        [blockBrowser failedWithMessageNotification:shouldLike ? @"点赞失败":@"取消点赞失败"];
    }];
}

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index{
    
    HGShareItem *item = [[HGShareItem alloc] init];
    item.text = @"";
    item.title = @"分享图片";
    item.itemType = HGShareItemTypeImage;
    NSURL *url = ((MWPhoto *)[photoBrowser.delegate photoBrowser:photoBrowser photoAtIndex:index]).photoURL;
    item.image = [UIImage imageWithContentsOfURL:url];
    __weak typeof(self) mySelf = self;
    self.shareViewController = [[HGShareViewController alloc] initWithShareItem:item completion:^{
        [HGPopContainerView dismiss];
        [mySelf.shareViewController removeFromParentViewController];
        mySelf.shareViewController = nil;
    }];
    [HGPopContainerView showWithView:self.shareViewController.view animtionDuration:0.3f TapToDismiss:YES];
}


#pragma mark - PopOver
-(UIView *)popView{
    if (_popView == nil) {
        _popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 60.5)];
        _popView.backgroundColor = [UIColor clearColor];
        _popView.userInteractionEnabled = YES;
        UIButton *btnTime =  [self popOverBtnWithTitle:@"时间" tag:0];
        btnTime.frame = CGRectMake(0, 0, 80, 30);
        [_popView addSubview:btnTime];
        
        HGOnePixelHeightView *sepView = [[HGOnePixelHeightView alloc] init];
        sepView.backgroundColor = RGBCOLOR(222, 222, 222);
        sepView.frame = CGRectMake(-10, 30, 100, 1);
        [_popView addSubview:sepView];
        
        UIButton *btnDownload = [self popOverBtnWithTitle:@"下载量" tag:1];
        btnDownload.frame = CGRectMake(0, 31, 80, 30);
        [_popView addSubview:btnDownload];
    }
    return _popView;
}

-(UIButton *)popOverBtnWithTitle:(NSString *)title tag:(NSInteger)tag{
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [btn setTitleColor:kCommonHoghtedColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(updateListOrder:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(IBAction)updateListOrder:(UIButton *)sender{
    [self.popOverView dismiss:YES];
    NSSortDescriptor *sortDescriptor = nil;
    //0 按时间 1 按下载量
    if (sender.tag==0) {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    }else{
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"download" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    NSArray *tmpArray = [self.allAblums sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.allAblums = [tmpArray mutableCopy];
    [self.tableView reloadData];
}

@end
