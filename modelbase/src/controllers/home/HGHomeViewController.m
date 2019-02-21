//
//  HGHomeViewController.m
//  modelbase
//
//  Created by HamGuy on 5/15/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGHomeViewController.h"
#import "HGAutoImageScroller.h"
#import "HGAblumSectionViewController.h"
#import "HGAblumCell.h"
#import "HGAblumHeaderView.h"
#import "HGAlertView.h"
#import "HGShreKitApi.h"
#import "HGAblumDetailInfoController.h"
#import "HGAblumService.h"
#import "MBProgressHUD.h"
#import <JDStatusBarNotification/JDStatusBarNotification.h>
#import "Cover.h"
#import <AFNetworking/AFNetworking.h>
#import "AnnounceMent.h"
#import "HGCycleScrollView.h"
#import "HGUserInfoService.h"
#import "HGAnnouceListController.h"

#define kTmpViewTag 444

@interface HGHomeViewController ()<HGAutoImageScrollerDatasource,HGAutoImageScrollerDatasource,HGAblumSectionViewControllerDelegate,HGCycleScrollViewDatasource,HGCycleScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView * scrollContainerView;
@property (nonatomic, strong) IBOutlet HGAutoImageScroller *autoImageScroller;

@property (nonatomic, strong) NSArray *banners;
@property (nonatomic, strong) NSArray *newsArray;
@property (nonatomic, strong) NSArray *vipArray;
@property (nonatomic, strong) NSArray *recArray;
@property (nonatomic, strong) NSArray *copArray;

@property (nonatomic, strong) HGAblumService *ablumService;

@property (nonatomic, strong) HGAblumSectionViewController *sectionViewNew;
@property (nonatomic, strong) HGAblumSectionViewController *sectionViewRec;
@property (nonatomic, strong) HGAblumSectionViewController *sectionViewVip;
@property (nonatomic, strong) HGAblumSectionViewController *sectionViewCop;

@property (nonatomic, strong) UIImage *normalBgIndex;
@property (nonatomic, strong) UIImage *highlightedBgIndex;

@property (nonatomic, strong) NSMutableArray *annouceList;
@property (nonatomic, strong) HGUserInfoService *userInfoService;
@property (nonatomic, strong) HGCycleScrollView *announceContainer;

@end

@implementation HGHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"模特基地";
        self.banners = [@[] copy];
        self.annouceList = [@{} mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addMoreButton];
    [self addRightButtonWithImage:[UIImage imageNamed:@"BtnRefesh"] highlight:[UIImage imageNamed:@"BtnRefeshPress"] action:@selector(getCovers)];
    
//    [self addRightButtonWithImage:[UIImage imageNamed:@"BtnRefesh"] highlight:[UIImage imageNamed:@"BtnRefeshPress"] action:@selector(test)];
    
    self.autoImageScroller.layer.cornerRadius = 2.f;
    self.autoImageScroller.layer.masksToBounds = YES;
    self.autoImageScroller.hidden = YES;
    
    _sectionViewNew = [[HGAblumSectionViewController alloc] initWithAblumSectionType:AblumSectionTypeNew];
    _sectionViewNew.view.frame = CGRectMake(0, 150, 320, 187);
    _sectionViewNew.delegate = self;
    //    _sectionViewNew.view.backgroundColor = [UIColor redColor];
    [self.scrollContainerView addSubview:_sectionViewNew.view];
    [self addChildViewController:_sectionViewNew];
    
    _sectionViewRec = [[HGAblumSectionViewController alloc]initWithAblumSectionType:AblumSectionTypeRec];
    _sectionViewRec.view.frame = CGRectMake(0, _sectionViewNew.view.bottom, 320, 187);
    _sectionViewRec.delegate = self;
    //    _sectionViewRec.view.backgroundColor = [UIColor greenColor];
    [self.scrollContainerView addSubview:_sectionViewRec.view];
    [self addChildViewController:_sectionViewRec];
    
    //    _sectionViewVip = [[HGAblumSectionViewController alloc]initWithAblumSectionType:AblumSectionTypeVip];
    //    _sectionViewVip.view.frame = CGRectMake(0, _sectionViewRec.view.top+_sectionViewRec.view.height, 320, 187);
    //    _sectionViewVip.delegate = self;
    //    [self.scrollContainerView addSubview:_sectionViewVip.view];
    //    [self addChildViewController:_sectionViewVip];
    
    _sectionViewCop = [[HGAblumSectionViewController alloc]initWithAblumSectionType:AblumSectionTypeCop];
    _sectionViewCop.view.frame = CGRectMake(0, _sectionViewRec.view.bottom, 320, 187);
    _sectionViewCop.delegate = self;
    //    _sectionViewCop.view.backgroundColor = [UIColor yellowColor];
    [self.scrollContainerView addSubview:_sectionViewCop.view];
    [self addChildViewController:_sectionViewCop];
    
    self.announceContainer = [[HGCycleScrollView alloc] initWithFrame:CGRectMake(0, _sectionViewCop.view.bottom, SCREEN_WIDTH, 120)];
    self.announceContainer.backgroundColor = [UIColor whiteColor];
    self.announceContainer.delegate = self;
    self.announceContainer.datasource = self;
    [self.scrollContainerView addSubview:self.announceContainer];
    
    self.scrollContainerView.contentSize = CGSizeMake(SCREEN_WIDTH, _announceContainer.bottom);
    
    //get cached
    //    self.banners = [Cover getCoversByType:@"banner"];
    //    self.newsArray = [Cover getCoversByType:@"new"];
    //    self.recArray = [Cover getCoversByType:@"master"];
    //    self.vipArray = [Cover getCoversByType:@"vip"];
    //    self.copArray = [Cover getCoversByType:@"cooper"];
    
    UITapGestureRecognizer *tapAnnounce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnnouce)];
    [self.announceContainer addGestureRecognizer:tapAnnounce];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpAnnouceList) name:kRefresAnnouceNotification object:nil];
    
    [self setUpCovers];
    [self getCovers];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUpAnnouceList];
}

-(HGAblumService *)ablumService{
    if (_ablumService == nil) {
        _ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _ablumService;
}

-(HGUserInfoService *)userInfoService{
    if (_userInfoService == nil) {
        _userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _userInfoService;
}

-(void)test{
    [self.ablumService delePhoto:@"1.jpg" fromAblum:@"dddd" Successed:^(MKNetworkOperation *completedOperation, id result) {
    
} error:^(NSError *error) {
    
}];

//    NSMutableDictionary *dict = [@{} mutableCopy];
//    dict[@"requesttype"]=@"personalimage";
//    //    dict[@"id"]=@"1123456421";
//    //    dict[@"image"]= @"1";
//    
//    [self.ablumService uploadImage:dict file:@"001.jpeg" progress:^(double progress) {
//    } Successed:^(MKNetworkOperation *completedOperation, id result) {
//        
//    } error:^(NSError *error) {
//        
//    }];
}

-(void)dealloc{
    [self.ablumService cancelAllOperations];
    self.ablumService = nil;
}

#pragma mark - Private
-(void)getCovers{
    [self loading];
    __weak typeof(self) mySelf = self;
    [self.ablumService getHomePageDataSuccessed:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        
        mySelf.banners = [dict objectForKey:@"banner"];
        if (mySelf.banners.count>0) {
            mySelf.autoImageScroller.hidden = NO;
        }
        [mySelf.autoImageScroller load];
        
        mySelf.newsArray = [dict objectForKey:@"new"];
        mySelf.recArray = [dict objectForKey:@"master"];
        //        mySelf.vipArray = [dict objectForKey:@"vip"];
        mySelf.copArray = [dict objectForKey:@"cooper"];
        
        [self setUpCovers];
        [mySelf successedWitnMessage:nil];
        
    } error:^(NSError *error) {
        [mySelf failedWithMessageNotification:@"获取列表失败！"];
    }];
    
}

-(void)setUpCovers{
    [self.sectionViewNew LoadData:self.newsArray];
    [self.sectionViewRec LoadData:self.recArray];
    //    [self.sectionViewVip LoadData:self.vipArray];
    [self.sectionViewCop LoadData:self.copArray];
}

-(void)setUpAnnouceList{
    [self loading];
    __weak typeof(self) mySelf = self;
    [self.userInfoService getAnnounceListSuccessed:^(MKNetworkOperation *completedOperation, id result) {
        [mySelf successedWitnMessage:nil];
        mySelf.annouceList = [result mutableCopy];
       
        for (UIView *vi in mySelf.announceContainer.subviews) {
            if (vi.tag == kTmpViewTag) {
                [vi removeFromSuperview];
            }
        }
        
        if (mySelf.annouceList.count<=3) {
            [mySelf.annouceList enumerateObjectsUsingBlock:^(AnnounceMent *annouceMent, NSUInteger idx, BOOL *stop) {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
                UIView *cubic = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 10, 10)];
                cubic.backgroundColor = kCommonHoghtedColor;
                cubic.clipsToBounds = YES;
                cubic.layer.cornerRadius = 5.f;
                [view addSubview:cubic];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 260, 20)];
                
                label.text = annouceMent.title;
                label.font = [UIFont systemFontOfSize:15.f];
                label.textColor = RGBCOLOR(91, 91, 91);
                label.tag = 888;
                [view addSubview:label];
                view.tag = kTmpViewTag;
                
                view.frame = CGRectOffset(view.frame, 0, view.frame.size.height * idx);
                [mySelf.announceContainer addSubview:view];
                view.userInteractionEnabled = YES;
                mySelf.announceContainer.height = (idx+1) * 40;
            }];
            mySelf.announceContainer.height = mySelf.annouceList.count * 40;
            mySelf.scrollContainerView.contentSize = CGSizeMake(SCREEN_WIDTH, _sectionViewCop.view.bottom+mySelf.announceContainer.height);
        }else{
            mySelf.announceContainer.height = 120;
            [mySelf.announceContainer reloadData];
            [mySelf.announceContainer autoScroll:30 timespan:2.0f];
        }
    } error:^(NSError *error) {
        if ([error code] == 4444) {
            mySelf.announceContainer.height = 40;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 260, 20)];
            
            label.text = @"暂无公告";
            label.font = [UIFont systemFontOfSize:15.f];
            label.textColor = RGBCOLOR(91, 91, 91);
            label.tag = 888;
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            [mySelf.announceContainer addSubview:view];
            [mySelf failedWithMessageNotification:nil];
            mySelf.scrollContainerView.contentSize = CGSizeMake(SCREEN_WIDTH, _sectionViewCop.view.bottom+mySelf.announceContainer.height);
        }else{
            [mySelf failedWithMessageNotification:[error domain]];
        }
     
    }];
    
}

#pragma mark - HGAutoImageScroller DataSource &&& Delegate
-(UIImage *)placeHolderImage{
    return nil;
}

-(NSInteger)imageCount{
    return _banners.count;
}

-(NSString *) imageUrlAtIndex:(NSInteger)index
{
    Cover *bannerCover = [self.banners objectAtIndex:index];
    NSString *url =  [NSString stringWithFormat:@"%@%@",kBannerUrl,bannerCover.path];
    DLog(@"url = %@",url);
    return url;
}

-(BOOL) autoScroll
{
    return YES;
}

-(CGFloat) animationDuration
{
    return 3.0f;
}

#pragma mark - HGImageScroller Delagate
-(void) didClickImageAtIndex:(NSInteger)index
{
    Cover *cover = _banners[index];
    if (cover.ablumid) {
        HGAblumDetailInfoController *controller = [[HGAblumDetailInfoController alloc] initWithType:AblumTypeNew ablumId:cover.ablumid];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - SectionView delegate
-(void)didCleckedButtonWithAblumType:(AblumSectionType)type{
    UIViewController *vc = nil;
    switch (type) {
        case AblumSectionTypeNew:
        vc = [AppDelegate newsAblumListController];
        break;
        case AblumSectionTypeRec:
        vc = [AppDelegate recAblumListController];
        break;
        case AblumSectionTypeVip:
        vc = [AppDelegate vipAblumListController];
        break;
        case AblumSectionTypeCop:
        vc = [AppDelegate copAblumListController];
        break;
        case AblumSectionTypeMine:
        
        break;
        case AblumSectionTypeDownloaded:
        
        break;
        
        default:
        break;
    }
    if(vc){
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)didClickedItemAtIndex:(int)index ablumType:(AblumSectionType)type{
    AblumType ablumType = AblumTypeNew;
    Cover *cover = nil;
    switch (type) {
        case AblumSectionTypeNew:{
            ablumType = AblumTypeNew;
            cover = _newsArray[index];
            break;
        }
        case AblumSectionTypeCop:{
            cover = _copArray[index];
            ablumType = AblumTypeCop;
            break;
        }
        case AblumSectionTypeRec:{
            cover = _recArray[index];
            ablumType = AblumTypeRec;
            break;
        }
        case AblumSectionTypeVip:{
            cover = _vipArray[index];
            ablumType = AblumTypeVip;
            break;
        }
        default:
        break;
    }
    if (cover.ablumid) {
        HGAblumDetailInfoController *controller = [[HGAblumDetailInfoController alloc] initWithType:ablumType ablumId:cover.ablumid];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

#pragma mark - HGCycleScrollview Delegate & dataSource

-(NSInteger)numberOfPages:(HGCycleScrollView *)scrollView{
    return self.annouceList.count;
}

-(UIView *)pageAtIndex:(NSInteger)index andScrollView:(HGCycleScrollView *)scrollView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    UIView *cubic = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 10, 10)];
    cubic.backgroundColor = kCommonHoghtedColor;
    cubic.clipsToBounds = YES;
    cubic.layer.cornerRadius = 5.f;
    [view addSubview:cubic];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 260, 20)];
    if (self.annouceList.count>3) {
        AnnounceMent *annouceMent = [self.annouceList objectAtIndex:index];
        label.text = annouceMent.title;
        label.font = [UIFont systemFontOfSize:15.f];
        label.textColor = RGBCOLOR(91, 91, 91);
        label.tag = 888;
        [view addSubview:label];
        view.tag = index;
    }
    return view;
}

-(void)tapAnnouce{
    HGAnnouceListController *controller = [[HGAnnouceListController alloc] initWithAnnounceList:self.annouceList];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
