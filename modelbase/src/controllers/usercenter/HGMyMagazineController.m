//
//  HGMyMagazineController.m
//  modelbase
//
//  Created by HamGuy on 5/19/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGMyMagazineController.h"
#import "HGAblumCell.h"
#import "HGEditAblumController.h"
#import "HGAblumDetailInfoController.h"
#import "Cover.h"
#import "Ablum.h"
#import "UIImageView+Loading.h"
#import "HGAddAblumController.h"
#import "HGUserInfoService.h"
#import "HGCurretUserContext.h"
#import "HGLocalAblumsManager.h"
#import "UIViewController+Acess.h"
#import "HGPhotoBroswerController.h"
#import "HGAblumService.h"
#import "HGShareKit.h"
#import "HGShareViewController.h"
#import "HGPopContainerView.h"
#import "HGSandboxHelper.h"
#import "HGAblumService.h"

#define kCellIndentify @"MyAblumCell"

@interface HGMyMagazineController ()<UICollectionViewDelegateFlowLayout,MWPhotoBrowserDelegate,HGAblumCellDelagate>

@property (nonatomic, assign) MyMagazineType currentType;
@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, strong) NSMutableArray *covers;
@property (nonatomic, strong) NSMutableArray *ablums;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) HGUserInfoService *userInfoService;
@property (nonatomic, strong) NSString *currentUserName;
@property (nonatomic, strong) NSString *currentId;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) HGShareViewController *shareViewController;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) HGAblumService* ablumService;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, strong) Ablum* currentAblum;

@end

@implementation HGMyMagazineController

- (id)initWithCovers:(NSArray *)covers
{
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layOut];
    if (self) {
        // Custom initialization
        self.title =  @"已下载的专辑";
        self.currentType = MyMagazineTypeDownladed;
        self.covers = [covers mutableCopy];
    }
    return self;
}

-(id)initWithUserName:(NSString *)userName{
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layOut];
    if (self) {
        if ([userName isEqualToString:[HGCurretUserContext sharedInstance].username]) {
            self.title = @"我的专辑";
        }else{
            self.title = [NSString stringWithFormat:@"%@ 的专辑",userName];
        }
        self.ablums = [@[]mutableCopy];
        self.currentType = MyMagazineTypeMine;
        self.currentUserName = userName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addbackButtonWithAction:@selector(goBack)];
    
    UICollectionViewFlowLayout *layOut=(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layOut.itemSize = CGSizeMake(95, 146);
    layOut.minimumInteritemSpacing = 9.5f;
    layOut.minimumLineSpacing = 10.f;
    layOut.sectionInset = UIEdgeInsetsMake(2, 8, 8, 8);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[HGAblumCell class] forCellWithReuseIdentifier:kCellIndentify];
    [self.collectionView registerNib:[HGAblumCell nib] forCellWithReuseIdentifier:kCellIndentify];
    self.isEditMode = NO;
    
    if (self.currentType == MyMagazineTypeDownladed) {
        [self addRightButtonWithImage:[UIImage imageNamed:@"IconEdit"] highlight:[UIImage imageNamed:@"IconEdtitPress"] action:@selector(editAblum)];
    }else{
        if (self.canUpload) {
            
            [self addRightButtonWithImage:[UIImage imageNamed:@"IconAdd"] highlight:[UIImage imageNamed:@"IconAddPress"] action:@selector(addMagazine)];
        }
        [self getMyAblums];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyAblums) name:kRefreshMyListNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.selectedIndex = 0;
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

-(HGAblumService *)ablumService{
    if (_ablumService == nil) {
        _ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _ablumService;
}

-(void)dealloc{
    [self.userInfoService cancelAllOperations];
    self.userInfoService = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRefreshMyListNotification object:nil];
}

#pragma mark - Actions

-(void)goBack{
    if (self.mm_drawerController.openSide==MMDrawerSideLeft) {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)editAblum{
    self.isEditMode = YES;
    [self addRightBarButtonWithName:@"完成" withAction:@selector(editDone)];
    [self.collectionView reloadData];
}

-(void)editDone{
    self.isEditMode = NO;
    [self addRightButtonWithImage:[UIImage imageNamed:@"IconEdit"] highlight:[UIImage imageNamed:@"IconEdtitPress"] action:@selector(editAblum)];
    [self.collectionView reloadData];
}

-(void)addMagazine{
    if (![self canUpload]) {
        return;
    }
    
    HGAddAblumController *controller = [[HGAddAblumController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)getMyAblums{
    [self loading];
    [self.ablums removeAllObjects];
    __weak typeof(self) mySelf = self;
    [self.userInfoService getAblumListWithUserName:self.currentUserName Successed:^(MKNetworkOperation *completedOperation, id result) {
        NSArray *array = result;
        [mySelf.ablums addObjectsFromArray:array];
        [mySelf.collectionView reloadData];
        [mySelf successedWitnMessage:nil];
    } error:^(NSError *error) {
        [mySelf failedWithMessageNotification:@"获取专辑列表失败！"];
    }];
    
}

-(IBAction)deleteAblum :(UIButton *)sender{
    
}

#pragma mark - UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.currentType == MyMagazineTypeDownladed ? _covers.count : _ablums.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    __block HGAblumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIndentify forIndexPath:indexPath];
    if (self.currentType== MyMagazineTypeDownladed) {
        
        NSString *ablumId = [self.covers objectAtIndex:indexPath.row];
        Cover *cover = [Cover coverForAblum:ablumId];
        
        NSString *imgPath = [[HGLocalAblumsManager sharedInstance] coverImagePathForAblum:ablumId];
        ablumId = nil;
        __block UIImage *img = nil;
        cell.imageView.image = [UIImage imageNamed:@"BgPlaceHoderSmall"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            img = [UIImage imageWithContentsOfFile:imgPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = img;
            });
        });
        cell.delegate = self;
        
        cell.titleLabel.text = cover.title;
        [cell changeToEditMode:self.isEditMode];
        cell.delButton.hidden = !self.isEditMode;
        return cell;
        
    }else{
        Ablum *ablum = [self.ablums objectAtIndex:indexPath.row];
        __block NSString *urlString = [NSString stringWithFormat:@"%@%@",kCoverUrl,ablum.path? : @""];
        if ([urlString isEqualToString:@""]) {
            urlString = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.jpg",kLocalCoverDirectoryName,ablum.ablumid]];
            __block UIImage *img = nil;
            cell.imageView.image = [UIImage imageNamed:@"BgPlaceHoderSmall"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                img = [UIImage imageWithContentsOfFile:urlString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = img;
                });
            });
        }else{
            [cell.imageView setImageShowingActivityIndicatorWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"BgPlaceHoderSmall"] failed:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = [UIImage imageNamed:@"BgImageFiledSmall"];
                });
            }];
        }
        cell.titleLabel.text = ablum.title;
        cell.delButton.hidden = NO;
        cell.delButton.tag = indexPath.row;
        cell.delegate = self;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isEditMode){
        NSString *ablumId = self.covers[indexPath.row];
        [self.covers removeObject:ablumId];
        [collectionView deleteItemsAtIndexPaths:@[indexPath]];
        [[HGLocalAblumsManager sharedInstance] deleteDownloadedAblum:ablumId];
    }else{
        if (self.currentType == MyMagazineTypeDownladed) {
            self.currentId = [self.covers objectAtIndex:indexPath.row];
            self.selectedIndex = indexPath.row;
            [self goToPhotoBrowser];
        }else{

            HGEditAblumController *controller = [[HGEditAblumController alloc] initWithCover:[self.ablums objectAtIndex:indexPath.row]];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - PhotoBrowser
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


-(NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.photos.count;
}

-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    if (index<self.photos.count) {
        return [self.photos objectAtIndex:index];
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
        [blockBrowser successedWitnMessage:shouldLike ? @"点赞成功":@"取消点赞成功"];
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
//    [photoBrowser addChildViewController:shareViewController];
    [HGPopContainerView showWithView:self.shareViewController.view animtionDuration:0.3f TapToDismiss:YES];
}

#pragma HGAblumCell Delegate
-(void)delButtonCickedOnCell:(HGAblumCell *)cell{
    __block NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    if (self.currentType == MyMagazineTypeMine) {
        Ablum *ablum = [self.ablums objectAtIndex:indexPath.row];
        __block NSString *ablumId = ablum.ablumid;
        __weak typeof(self)mySelf = self;
        [UIAlertView showWithTitle:@"提示" message:[NSString stringWithFormat:@"确定删除专辑 %@ ？",cell.titleLabel.text] cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [mySelf.ablumService deleteAblum:ablumId Successed:^(MKNetworkOperation *completedOperation, id result) {
                    [mySelf successedWitnMessage:@"删除专辑成功"];
                    [mySelf.ablums removeObjectAtIndex:indexPath.row];
                    [mySelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    // TODO 删除本地存储的专辑信息（封面，标题等）
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil];
                } error:^(NSError *error) {
                    [mySelf failedWithMessageNotification:@"删除专辑成功"];
                }];
            }
        }];
    }else{
        NSString *ablumId = self.covers[indexPath.row];
        [self.covers removeObject:ablumId];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        [[HGLocalAblumsManager sharedInstance] deleteDownloadedAblum:ablumId];
    }
}

@end
