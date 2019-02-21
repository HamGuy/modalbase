//
//  HGAblumDetailInfoController.m
//  modelbase
//
//  Created by HamGuy on 5/20/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumDetailInfoController.h"
#import "HGAblumInfoCell.h"
#import "HGPopContainerView.h"
#import "HGShareItem.h"
#import "HGShareViewController.h"
#import "HGPhotoBroswerController.h"
#import "HGPhoto.h"
#import "NSString+LineSpace.h"
#import "HGAblumService.h"
#import "Ablum.h"
#import "MBProgressHUD.h"
#import "HGUserCenterController.h"
#import "UIImageView+Loading.h"
#import "HGLocalAblumsManager.h"
#import "HGSandboxHelper.h"
#import "UIViewController+Acess.h"

@interface HGAblumDetailInfoController ()<UIScrollViewDelegate,MWPhotoBrowserDelegate>

@property (nonatomic, assign) AblumType currentAblumType;
@property (nonatomic, strong) HGShareItem *itemToShare;
@property (nonatomic, strong) HGShareViewController *shareViewController;
@property (nonatomic, strong) HGAblumService *ablumService;

@property (nonatomic, weak) IBOutlet UIButton *readOrDownloadBtn;
@property (nonatomic, strong) Ablum *currentAblum;
@property (nonatomic, strong) NSString *currentId;
@property (nonatomic, strong) NSArray *listData;

@property (nonatomic, strong) IBOutlet UIView *indicatorContainerView;
@property (nonatomic, strong) IBOutlet DACircularProgressView *downloadIndicator;


//Header
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *likeLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadLabel;
@property (nonatomic, weak) IBOutlet UIImageView *coverImgView;

//scrollview
@property (nonatomic, weak) IBOutlet UIScrollView *previewImageContainerView;

//browser
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) UIViewController* leftViewController;
@end

@implementation HGAblumDetailInfoController

-(id)initWithType:(AblumType)type ablum:(Ablum *)ablum{
    self = [super initWithNibName:@"HGAblumDetailInfoController" bundle:nil];
    if(self){
        self.currentAblumType = type;
        self.currentAblum = ablum;
        self.currentId = ablum.ablumid;
        self.ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return self;
}

-(id)initWithType:(AblumType)type ablumId:(NSString *)aid{
    if(self){
        self.currentAblumType = type;
        self.currentId = aid;
        self.ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.leftViewController = self.mm_drawerController.leftDrawerViewController;
    [self.mm_drawerController setLeftDrawerViewController:nil];
    [((HGNavigationController *)self.navigationController) setNavigationBarStyle:HGNavigationBarStyleDefault];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setLeftDrawerViewController:self.leftViewController];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[SDWebImageManager sharedManager].imageCache clearMemory];
//    HGAppDelegate *delegate = AppDelegate;
//    delegate.userCenterController = nil;
//    delegate.homeViewController = nil;
//    delegate.recAblumListController=nil;
//    delegate.vipAblumListController=nil;
//    delegate.copAblumListController = nil;
//    delegate.newsAblumListController = nil;
}

-(HGAblumService *)ablumService{
    if (_ablumService == nil) {
        _ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _ablumService;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self setUpTitle];
    self.title = @"详情";
    [self setUpHeaderInfo];
//    [self setUpPreviewImages];
    [self addbackButtonWithAction:@selector(goBack)];
    [self addRightButtonWithImage:[UIImage imageNamed:@"IconShare"] highlight:[UIImage imageNamed:@"IconSharePress"] action:@selector(showShareController)];
    
}

-(void)dealloc{
    [self.ablumService cancelAllOperations];
    self.ablumService = nil;
}

-(void)goBack{
    if (self.mm_drawerController.openSide==MMDrawerSideLeft) {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)showShareController{
    if (self.shareViewController == nil) {
        self.shareViewController = [[HGShareViewController alloc] initWithShareItem:self.itemToShare completion:^{
            [HGPopContainerView dismiss];
        }];
    }
    [HGPopContainerView showWithView:self.shareViewController.view animtionDuration:0.3f TapToDismiss:YES];
}

-(HGShareItem *)itemToShare{
    HGShareItem *item = [[HGShareItem alloc] init];
    item.text = @"模特基地";
    item.title = @"分享图片";
    item.itemType = HGShareItemTypeImage;
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kCoverUrl,self.currentAblum.path];
    item.image = [UIImage imageWithContentsOfURL:[NSURL URLWithString:urlString]];
    return item;
}


#pragma mark - Actions
-(IBAction)viewPhotos:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"下载"]) {
        if (![self canDownload]) {
            return;
        }
        
        
        @autoreleasepool {
        
        __weak typeof(self) mySelf = self;
        self.indicatorContainerView.hidden = NO;
        self.downloadIndicator.progress = 0;
        self.downloadIndicator.trackTintColor = [UIColor whiteColor];
        self.downloadIndicator.progressTintColor = kCommonHoghtedColor;
        NSString *pathToStore = [[[HGSandboxHelper sharedInstance] getAppTmpDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"ablum%@.zip",mySelf.currentAblum.ablumid]];
        
        [self.ablumService downloadAblumWithId:self.currentAblum.ablumid toFile:pathToStore progress:^(double progress) {
            [mySelf.downloadIndicator setProgress:progress animated:YES];
        } Successed:^(MKNetworkOperation *completedOperation, id result) {
            DLog(@"download success");
            [[HGLocalAblumsManager sharedInstance] addDownloadedAblum:mySelf.currentAblum.ablumid];
            [[HGLocalAblumsManager sharedInstance] unZipAblum:mySelf.currentAblum.ablumid fromTmpFilePath:result];
            
            NSData *data = UIImageJPEGRepresentation(mySelf.coverImgView.image, 1.0);
            [[HGLocalAblumsManager sharedInstance] addCoverImage:data forAblum:mySelf.currentAblum.ablumid];
            
            mySelf.downloadIndicator.progress = 1;
            [UIView animateWithDuration:0.2 animations:^{
                mySelf.indicatorContainerView.hidden = YES;
            } completion:^(BOOL finished) {
                [mySelf.readOrDownloadBtn setTitle:@"立刻阅读" forState:UIControlStateNormal];
            }];
            [mySelf successedWitnMessage:nil];
        } error:^(NSError *error) {
            [mySelf failedWithMessage:@"下载专辑失败：请求超时，请稍后重试！" conmpleted:nil];
            mySelf.indicatorContainerView.hidden = YES;
        }];
        }
    }else{
        [self goToPhotoBrowser];
    }
    
}

-(IBAction)tapAuthor:(UITapGestureRecognizer *)sender{
    HGUserCenterController *controller = [[HGUserCenterController alloc] initWithUserName:self.currentAblum.edit];
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)tapScrollview:(UITapGestureRecognizer *)gesture{
    if ([self.readOrDownloadBtn.titleLabel.text isEqualToString:@"立刻阅读"]) {
        [self goToPhotoBrowser];
    }
}

#pragma mark - Private

-(void)setUpTitle{
    NSString *strTitle;
    switch (self.currentAblumType) {
        case AblumTypeNew:
            strTitle = @"新片速递";
            break;
        case AblumTypeRec:
            strTitle = @"推荐大师";
            break;
        case AblumTypeCop:
            strTitle = @"合作专区";
            break;
        case AblumTypeVip:
            strTitle = @"实力会员";
            break;
        case AblumTypeSearch:
            strTitle = @"搜索";
        default:
            break;
    }
    self.title = [NSString stringWithFormat:@"%@详情",strTitle];
}

-(void)setUpHeaderInfo{
    //如果传入的是专辑信息，则直接显示
    if (self.ablumService == nil) {
        [self setUpInfoWithAblum:self.currentAblum];
        self.currentId = self.currentAblum.ablumid;
    }else{//否者查询本地是否有该专辑，如果有，直接调取显示，否则发起请求，请求专辑信息
        self.currentAblum = nil;//[Ablum getAblumWithId:self.currentId];
        if (self.currentAblum) {
            [self setUpInfoWithAblum:self.currentAblum];
            self.currentId = self.currentAblum.ablumid;
        }else{
            [self loading];
            __weak typeof(self) mySelf = self;
            
            [self.ablumService getAblunmDetailWithId:self.currentId Successed:^(MKNetworkOperation *completedOperation, id result) {
                mySelf.currentAblum = result;
                [mySelf setUpInfoWithAblum:result];
                [mySelf successedWitnMessage:nil];
            } error:^(NSError *error) {
                [mySelf failedWithMessageNotification:@"获取专辑详情失败！"];
            }];
        }
    }
}

-(void)setUpInfoWithAblum:(Ablum *)ablum{
    BOOL ablumDownloaded = [[HGLocalAblumsManager sharedInstance] isAlreadyDownLoaded:self.currentAblum.ablumid];
    NSString *btnTitle = ablumDownloaded ? @"立刻阅读":@"下载";
    [self.readOrDownloadBtn setTitle:btnTitle forState:UIControlStateNormal];
    self.titleLabel.text = ablum.title;
    self.authorLabel.text = [NSString stringWithFormat:@"作者：%@",ablum.edit];
    self.likeLabel.text = ablum.good;
    self.downloadLabel.text = ablum.download;
    NSString *strDescription = ablum.abdescription ? : @"暂无描述";//@"模特基地外拍活动，见证了一个又一个平凡的小女生在模特地覅变成女神的过程，她们点亮了自己的梦想.模特基地新片速递 - 校园女神";
    _descriptionLabel.attributedText =[strDescription attributedStringWithLineSpace:2.f];
    [_descriptionLabel sizeToFit];
    __weak typeof(self) mySelf = self;
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kCoverUrl,ablum.path];
    [self.coverImgView setImageShowingActivityIndicatorWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"BgPlaceHoderSmall"] failed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            mySelf.coverImgView.image = [UIImage imageNamed:@"BgImageFiledSmall"];
        });
    }];
    [self setUpPreviewImages:ablum.quick];
    
}

-(void)setUpPreviewImages:(NSString *)thumpath{
    if (thumpath ) {
//    UIImage *img = [UIImage imageNamed:@"test2"];
        NSString *stringPath = nil;
        UIImageView *imgView = nil;
        @autoreleasepool {
            
        
    for (NSInteger i = 0; i<5; i++) {
        imgView  = [[UIImageView alloc] initWithFrame: CGRectMake(209*i,0,200,350)];
        if (i==0) {
            imgView.left += i*8;
        }
        stringPath = [NSString stringWithFormat:@"%@%@%ld.jpg",kBaseImageUrl,thumpath,(long)i+1];
        __weak UIImageView *weakImageView = imgView;
        [imgView setImageShowingActivityIndicatorWithURL:[NSURL URLWithString:stringPath] placeholderImage:[UIImage imageNamed:@"BgPlaceHolderMiddle"] failed:^{
            weakImageView.image = [UIImage imageNamed:@"BgImageFailedMiddle"];
        }];
        [self.previewImageContainerView addSubview:imgView];
    }
        self.previewImageContainerView.contentSize = CGSizeMake(1045, is_iPhone5 ? 350 : 260);
        if (!is_iPhone5) {
            self.previewImageContainerView.height = 260;
        }
    }
    }
}

-(void)goToPhotoBrowser{
    __block MWPhoto *photo = nil;
    self.photos = [NSMutableArray array];
    
    NSArray *allPics = [[HGLocalAblumsManager sharedInstance] allPicsOfAblum:self.currentAblum.ablumid];
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
    BOOL couldLike = self.currentAblum.goodme == 0 ? YES : NO;
    [controller updateLikeButtonStatus:couldLike];

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

-(void)didClickLikeButton:(MWPhotoBrowser *)photoBrowser{
    [photoBrowser loading];
    __block HGAblumService *service = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    __block MWPhotoBrowser *blockBrowser = photoBrowser;
    __block BOOL shouldLike = self.currentAblum.goodme == 0 ? YES : NO;
    __weak typeof(self)mySelf = self;
    [service postLikeWithBookId:self.currentId isLike:shouldLike Successed:^(MKNetworkOperation *completedOperation, id result) {
        service=nil;
        [blockBrowser successedWitnMessage:shouldLike ? @"点赞成功":@"取消点赞成功"];
        [blockBrowser updateLikeButtonStatus:!shouldLike];
        mySelf.currentAblum.goodme = shouldLike ? 1 : 0;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } error:^(NSError *error) {
        service = nil;
        [blockBrowser failedWithMessageNotification:shouldLike ? @"点赞失败":@"取消点赞失败"];
    }];
}

-(NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index{
    return [NSString stringWithFormat:@"%lu/%lu",(unsigned long)index+1,(unsigned long)_photos.count];
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
//    [self addChildViewController:self.shareViewController];
    [HGPopContainerView showWithView:self.shareViewController.view animtionDuration:0.3f TapToDismiss:YES];
}
@end
