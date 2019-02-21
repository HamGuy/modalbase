//
//  HGUserCenterController.m
//  modelbase
//
//  Created by HamGuy on 5/19/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGUserCenterController.h"
#import "HGAblumSectionViewController.h"
#import "HGMyMagazineController.h"
#import "UserInfo.h"
#import "MBProgressHUD.h"
#import "HGUserInfoService.h"
#import "HGCurretUserContext.h"
#import "HGEditUserInfoControllerr.h"
#import "UIImageView+Loading.h"
#import "HGAblumDetailInfoController.h"
#import "Cover.h"
#import "HGLocalAblumsManager.h"
#import "HGPhotoBroswerController.h"
#import "HGShareItem.h"
#import "HGShareViewController.h"
#import "HGPopContainerView.h"
#import "HGAblumService.h"
#import "HGSandboxHelper.h"
#import "HGAddAblumController.h"
#import "UIViewController+Acess.h"
#import "UIImageView+Rounded.h"
#import "Ablum.h"

@interface HGUserCenterController ()<HGAblumSectionViewControllerDelegate,MWPhotoBrowserDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *bgimageview;
@property (nonatomic, weak) IBOutlet UIImageView *avataImgView;
@property (nonatomic, weak) IBOutlet UIImageView *vipTagImgView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *professionalLabel;
@property (nonatomic, weak) IBOutlet UILabel *introductionLabel;;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollContainderView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIButton *logoutBtn;

@property (nonatomic, strong) HGAblumSectionViewController *myAblumSection;
@property (nonatomic, strong) HGAblumSectionViewController *myDownloadSection;
@property (nonatomic, strong) UserInfo *currentUserinfo;
@property (nonatomic, strong) NSString *currentUsername;
@property (nonatomic, strong) HGUserInfoService *userInfoService;
@property (nonatomic, strong) NSMutableArray *ablums; //我的专辑
@property (nonatomic, strong) NSMutableArray *downloads; //我的下载
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSString *currentId;
@property (nonatomic, strong) UILabel *nilAblumTipLabel;
@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, strong) NSMutableDictionary *myLocalTitles;
@property (nonatomic, strong) NSArray *myLocalPis;
@property (nonatomic, strong) HGShareViewController *shareViewController;

@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, strong) HGAblumService* ablumService;
@property (nonatomic, strong) Ablum* currentAblum;
@end

@implementation HGUserCenterController

-(id)initWithUserName:(NSString *)userName{
    self = [super initWithNibName:@"HGUserCenterController" bundle:nil];
    if (self) {
        // Custom initialization
        self.currentUsername = userName;
        self.userNameLabel.text = userName;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addMoreButton];
    
    _myAblumSection = [[HGAblumSectionViewController alloc] initWithAblumSectionType:AblumSectionTypeMine];
    _myAblumSection.view.frame = CGRectMake(0, 165, 320, 184);
    _myAblumSection.delegate = self;
    _myAblumSection.view.alpha = 0;
//    _myAblumSection.view.backgroundColor = [UIColor greenColor];
    [self.avataImgView roundedWithBorderWidth:2.f borderColor:[UIColor whiteColor]];
    [self.scrollContainderView addSubview:_myAblumSection.view];
    [self addChildViewController:self.myAblumSection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userinfoModified:) name:kShouldRefreshUserNotification object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self isCurrentUser]) {
        [self addMoreButton];
        [self addRightButtonWithImage:[UIImage imageNamed:@"IconEdit"] highlight:[UIImage imageNamed:@"IconEdtitPress"] action:@selector(editUserInfo)];
        
    }else{
        [self addbackButtonWithAction:@selector(goBack)];
    }
    self.logoutBtn.hidden = ![self isCurrentUser];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.title = @"个人主页";
    self.ablums = [@[] mutableCopy];
    self.downloads = [[[HGLocalAblumsManager sharedInstance] allAblums] mutableCopy];
    [self setUpUsrInfo];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShouldRefreshUserNotification object:nil];
    [self.userInfoService cancelAllOperations];
    [self.ablumService cancelAllOperations];
    self.ablumService = nil;
    self.userInfoService = nil;
}

#pragma mark - geteer
-(HGUserInfoService *)userInfoService{
    if(_userInfoService == nil){
        _userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _userInfoService;
}

-(HGAblumService *)ablumService{
    if (_ablumService == nil) {
        _ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _ablumService;
}

-(UILabel *)nilAblumTipLabel{
    if (_nilAblumTipLabel == nil) {
        _nilAblumTipLabel = [[UILabel alloc] init];
        _nilAblumTipLabel.text = @"暂无专辑，点此新建";
        _nilAblumTipLabel.backgroundColor = [UIColor clearColor];
        _nilAblumTipLabel.textColor = RGBCOLOR(91, 91, 91);
        _nilAblumTipLabel.font = [UIFont systemFontOfSize:20.f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLable)];
        [_nilAblumTipLabel addGestureRecognizer:tap];
        _nilAblumTipLabel.userInteractionEnabled = YES;
        _nilAblumTipLabel.textAlignment = NSTextAlignmentCenter;
        _nilAblumTipLabel.frame = _myAblumSection.view.bounds;
        _nilAblumTipLabel.height -= 30;
        _nilAblumTipLabel.top += 50;
    }
    return _nilAblumTipLabel;
}

-(NSMutableDictionary *)myLocalTitles{
    if (_myLocalTitles == nil) {
        _myLocalTitles = [[HGLocalAblumsManager sharedInstance] allLocalTitles];
    }
    return _myLocalTitles;
}

//-(NSArray *)myLocalPis{
//    if (_myLocalPis == nil) {
//        _myLocalPis = [[HGLocalAblumsManager sharedInstance] allLocalPicsOfAblum:self.currentId];
//    }
//}
#pragma mark - action

-(void)goBack{
    if (self.mm_drawerController.openSide==MMDrawerSideLeft) {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kShoudResetSelectIndexNotification object:nil];
    }
}

-(void)editUserInfo{
    HGEditUserInfoControllerr *controller = [[HGEditUserInfoControllerr alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)tapLable{
    HGAddAblumController *controller = [[HGAddAblumController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)logOut:(id)sender{
    __weak typeof(self)mySelf = self;
    [UIAlertView showWithTitle:@"提示" message:@"确定注销当前登录用户？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==1) {
            [[HGCurretUserContext sharedInstance] logout];
            mySelf.currentUsername = nil;
            mySelf.currentAblum = nil;
            mySelf.currentUserinfo = nil;
            mySelf.ablums = nil;
            mySelf.downloads = nil;
            HGNavigationController *nav = [[HGNavigationController alloc] initWithRootViewController:[AppDelegate loginController]];
            [mySelf presentViewController:nav animated:YES completion:^{
                HGAppDelegate *delegate =AppDelegate;
                delegate.userCenterController = nil;
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShoudResetSelectIndexNotification object:nil];

        }
    }];
}

#pragma mark - Private
-(BOOL)isCurrentUser{
    return self.currentUsername != nil && [[HGCurretUserContext sharedInstance].username isEqualToString:self.currentUsername];
}

-(void)userinfoModified:(NSNotification *)notify{
    NSDictionary *dic = [notify userInfo];
    if (dic) {
        self.currentUserinfo.userdescrption = [dic objectForKey:@"des"];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        self.needUpdate = YES;
        
        SDImageCache *cache = [SDImageCache sharedImageCache];
        [cache clearMemory];
        [cache clearDisk];
        [cache cleanDisk];
    }else{
        self.needUpdate = YES;
        [self setUpUsrInfo];
    }
}

-(void)setUpUsrInfo{
    if (self.currentUsername==nil) {
        self.currentUsername = [HGCurretUserContext sharedInstance].username;
        DLog(@"current username = %@",self.currentUsername);
    }
    
    if ([self isCurrentUser] && !self.needUpdate) {
        self.currentUserinfo = [UserInfo userInfoWithUserNmae:self.currentUsername];
    }
    else{
        self.currentUserinfo = nil;
    }
    
    if (self.currentUserinfo) {
        [self configUserInfo:self.currentUserinfo];
    }else
    {
        
        [self loading];
        
        __weak typeof(self) mySelf = self;
        [self.userInfoService getUserInfoWithName:self.currentUsername Successed:^(MKNetworkOperation *completedOperation, id result) {
            UserInfo *info = result;
            mySelf.currentUserinfo = info;
            [mySelf configUserInfo:info];
            [mySelf successedWitnMessage:nil];
            mySelf.needUpdate = NO;
        } error:^(NSError *error) {
            [mySelf failedWithMessageNotification:@"获取个人信息失败！"];
        }];
    }
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

-(NSString *)titleForUserType:(NSString *)type{
    if ([type isEqualToString:kUserTypeUser]) {
        return @"会员";
    }
    
    if ([type isEqualToString:kUserTypeModel]) {
        return @"模特";
    }
    else if ([type isEqualToString:kUserTypeEditor]) {
        return @"编辑";
    }else if([type isEqualToString:kUserTypeVIP]){
        return @"VIP会员";
    }
    return nil;
}

-(void)configUserInfo:(UserInfo *)info{
    if (self.ablums) {
        [self.ablums removeAllObjects];
    }
    self.professionalLabel.text = [NSString stringWithFormat:@"职业：%@",info.role ? [self titleForUserType:info.role]:@""];
    self.introductionLabel.text = [NSString stringWithFormat:@"描述：%@",info.userdescrption ? : @"暂无描述"];
    self.userNameLabel.text = info.username;
    
    __weak typeof(self) mySelf = self;
    if (info.head) {
        __block UIImage *img = nil;
        __block NSString *strUrl = info.head;
        self.avataImgView.image = [UIImage imageNamed:@"IConDefaultAvata"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (img) {
                    mySelf.avataImgView.image = img;
                }
            });
        });
    }
    
    self.vipTagImgView.image = [self imageForUserType:info.role];
    
    [info.images enumerateObjectsUsingBlock:^(Cover *obj, NSUInteger idx, BOOL *stop) {
        if (obj.title.length==0 && mySelf.myLocalTitles.count>0) {
            obj.title = [mySelf.myLocalTitles objectForKey:obj.ablumid];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        [mySelf.ablums addObject:obj];
    }];

    //是否有相册
    if (self.ablums.count == 0) {
        //是否是当前用户
        if ([self isCurrentUser]) {
            if ([HGCurretUserContext sharedInstance].allowUpLoad ) {//允许上传，添加创建专辑提示
                _myAblumSection.view.hidden =NO;
                _myAblumSection.view.alpha = 1;
                [_myAblumSection LoadData:self.ablums];
                [_myAblumSection.view addSubview:self.nilAblumTipLabel];
            }else{
                _myAblumSection.view.hidden = YES;
                _myDownloadSection.view.hidden = YES;
            }
        }else{
            _myAblumSection.view.hidden =NO;
            _myAblumSection.view.alpha = 1;
            self.nilAblumTipLabel.text = @"该用户尚未创建专辑";
            [_myAblumSection.view addSubview:self.nilAblumTipLabel];
        }
        [_myAblumSection hideNavButton:![self isCurrentUser]];

    }else{
        if (_nilAblumTipLabel && [_myAblumSection.view.subviews containsObject:_nilAblumTipLabel]) {
            [_nilAblumTipLabel removeFromSuperview];
            _nilAblumTipLabel = nil;
        }
        
        
        [_myAblumSection hideNavButton:![self isCurrentUser]];
        [_myAblumSection LoadData:self.ablums];
        [UIView animateWithDuration:0.3f animations:^{
            _myAblumSection.view.alpha=1;
        }];
    }
    
    if ([self isCurrentUser]) {
        if (self.downloads.count == 0) {
            _myDownloadSection.view.hidden = YES;
        }else{
            if (_myDownloadSection == nil) {
                _myDownloadSection = [[HGAblumSectionViewController alloc] initWithAblumSectionType:AblumSectionTypeDownloaded];
            }
            
            if (!_myDownloadSection.view.superview) {
                _myDownloadSection.delegate = self;
                _myDownloadSection.view.alpha = 0;
                [self.scrollContainderView addSubview:_myDownloadSection.view];
                [self addChildViewController:_myDownloadSection];
            }
                if (self.myAblumSection.view.hidden) {
                    _myDownloadSection.view.frame = CGRectMake(0, 165, 320, 184);
                }else{
                    _myDownloadSection.view.frame = _myAblumSection.view.bounds;
                    _myDownloadSection.view.top = _myAblumSection.view.bottom+8.f;
                }
            self.scrollContainderView.contentSize = CGSizeMake(320, _myDownloadSection.view.bottom+ (IS_IOS6() ? (is_iPhone5 ? 66 :150) : (is_iPhone5 ? 70 : 150)));
            
            [_myDownloadSection LoadData:self.downloads];[UIView animateWithDuration:0.3f animations:^{
                    _myDownloadSection.view.alpha=1;
                    _myDownloadSection.view.hidden=NO;
                }];
        }
    }else{
        self.scrollContainderView.contentSize = [UIScreen mainScreen].bounds.size;
    }
}

#pragma mark - HGSectionView Delegate
-(void)didCleckedButtonWithAblumType:(AblumSectionType)type{
    if (type==AblumSectionTypeDownloaded) {
        HGMyMagazineController *controller = [[HGMyMagazineController alloc] initWithCovers:self.downloads];
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        HGMyMagazineController *controller = [[HGMyMagazineController alloc] initWithUserName:self.currentUsername];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)didClickedItemAtIndex:(int)index ablumType:(AblumSectionType)type{
    
    if (type==AblumSectionTypeMine) {
        Cover *cover = self.ablums[index];
        HGAblumDetailInfoController *controller = [[HGAblumDetailInfoController alloc] initWithType:AblumTypeSearch ablumId:cover.ablumid];
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        self.currentId = self.downloads[index];
        [self goToPhotoBrowser];
    }
}


-(void)goToPhotoBrowser{
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
    //    photo = [MWPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@1.jpg",kBaseImageUrl,self.currentAblum.quick]]];
    //    [_photos addObject:photo];
    //
    //    photo = [MWPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@2.jpg",kBaseImageUrl,self.currentAblum.quick]]];
    //    [_photos addObject:photo];
    //
    //
    //    photo = [MWPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@3.jpg",kBaseImageUrl,self.currentAblum.quick]]];
    //    [_photos addObject:photo];
    //
    //    photo = [MWPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@4.jpg",kBaseImageUrl,self.currentAblum.quick]]];
    //    [_photos addObject:photo];
    //
    //    photo = [MWPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@5.jpg",kBaseImageUrl,self.currentAblum.quick]]];
    //    [_photos addObject:photo];
    
    __block HGPhotoBroswerController *controller = [[HGPhotoBroswerController alloc] initWithDelegate:self];
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
    if (!self.isNetworkEnabled) {
        Ablum *ablum = [Ablum getAblumWithId:self.currentId];
        if (ablum) {
            BOOL couldLike = ablum.goodme == 0 ? YES : NO;
            [controller updateLikeButtonStatus:couldLike];
            mySelf.currentAblum = ablum;
        }
    }else{
        __weak typeof(self)mySelf = self;
        [self.ablumService getAblunmDetailWithId:self.currentId Successed:^(MKNetworkOperation *completedOperation, id result) {
            Ablum *ablum = result;
            BOOL couldLike = ablum.goodme == 0 ? YES : NO;
            mySelf.isLiked = couldLike;
            [controller updateLikeButtonStatus:couldLike];
            mySelf.currentAblum = ablum;
        } error:^(NSError *error) {
            Ablum *ablum = [Ablum getAblumWithId:mySelf.currentId];
            if (ablum) {
                BOOL couldLike = ablum.goodme == 0 ? YES : NO;
                [controller updateLikeButtonStatus:couldLike];
                self.currentAblum = ablum;
            }
        }];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    
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
    __weak typeof(self)mySelf = self;
    BOOL shouldLike = self.currentAblum.goodme == 0 ? YES : NO;
    [service postLikeWithBookId:self.currentId isLike:shouldLike Successed:^(MKNetworkOperation *completedOperation, id result) {
        service=nil;
        [blockBrowser successedWitnMessage:shouldLike? @"点赞成功":@"取消点赞成功"];
        [blockBrowser updateLikeButtonStatus:!shouldLike];
        mySelf.currentAblum.goodme = shouldLike ? 1 : 0;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } error:^(NSError *error) {
        service = nil;
        [blockBrowser failedWithMessageNotification:mySelf.isLiked ? @"点赞失败":@"取消点赞失败"];
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

@end
