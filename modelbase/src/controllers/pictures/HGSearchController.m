//
//  HGSearchController.m
//  modelbase
//
//  Created by HamGuy on 5/28/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGSearchController.h"
#import "Ablum.h"
#import "HGAblumInfoCell.h"
#import "HGAblumService.h"
#import "HGPhotoBroswerController.h"
#import "HGShareViewController.h"
#import "HGPopContainerView.h"
#import "HGAblumDetailInfoController.h"
#import "HGShareItem.h"
#import "HGSandboxHelper.h"
#import "HGLocalAblumsManager.h"
#import "UIViewController+Acess.h"
#import "HGUserListController.h"

@interface HGSearchController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,HGAblumInfoCellDelegate,MWPhotoBrowserDelegate>

//@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *typeSegment;

@property (nonatomic, strong) NSMutableArray *searchReults;
@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) HGAblumService *ablumService;
@property (nonatomic, strong) UINib *ablumInfoCellNib;
@property (nonatomic, strong) NSString *currentId;
@property (nonatomic, strong) HGShareViewController *shareViewController;

@property (nonatomic, strong) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UITextField *seachField;
@property (nonatomic, weak) IBOutlet UIView *indicatorView;

@property (nonatomic, weak) IBOutlet UIButton *btn1;
@property (nonatomic, weak) IBOutlet UIButton *btn2;

@property (nonatomic, assign) NSInteger currentSearchType; //0 用户 1 专辑
@property (nonatomic, strong) IBOutlet UIView *userCategoryView;
@property (nonatomic, weak) IBOutlet UIView *innerContainerView;
@property (nonatomic, weak) IBOutlet UIButton *btnMoel;
@property (nonatomic, weak) IBOutlet UIButton *btnAjent;
@property (nonatomic, weak) IBOutlet UIButton *btnVIP;

@property (nonatomic, weak) IBOutlet UILabel *labelModel;
@property (nonatomic, weak) IBOutlet UILabel *labelEditor;
@property (nonatomic, weak) IBOutlet UILabel *labelVIP;

@property (nonatomic, assign) NSInteger currentRoletype; //-1 all 0 model 1 edit 2 vip
@property (nonatomic, assign) NSInteger selectedIndex;


@end

@implementation HGSearchController

- (id)init
{
    self = [super initWithNibName:@"HGSearchController" bundle:nil];
    if (self) {
        // Custom initialization
        self.searchReults = [@[] mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addMoreButton];
    [self addRightBarButtonWithName:@"搜索" withAction:@selector(wantSearch)];
    self.navigationItem.titleView = self.titleView;
    self.typeSegment.tintColor = kCommonHoghtedColor;
    self.currentSearchType = 0;
    self.currentRoletype = -1;
    self.tableView.alpha = 0;
    
    self.innerContainerView.layer.borderColor = [RGBCOLOR(204, 204, 204) CGColor];
    self.innerContainerView.layer.borderWidth = 0.5f;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.view addGestureRecognizer:tap];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.backgroundColor = RGBCOLOR(234, 234, 234);
//    [self.seachField becomeFirstResponder];
    self.selectedIndex = 0;
    [self.btn1 setTitleColor:kCommonHoghtedColor forState:UIControlStateNormal];
}


-(void)dealloc{
    [self.ablumService cancelAllOperations];
    self.ablumService = nil;
}

- (void)hideKeyboard
{
    [self.seachField resignFirstResponder];
}

-(void)cancelSeach{
    self.seachField.text = nil;
    [self hideKeyboard];
}

-(void)wantSearch{
    
    if (self.currentSearchType == 1) {
        if (self.seachField.text.length == 0) {
            return;
        }
        [self hideKeyboard];
        [self searchWithCondition:self.seachField.text];
    }else{
        NSMutableDictionary *condition = [@{} mutableCopy];
        condition[@"requesttype"] = @"searchuser";
        NSString *title = self.seachField.text.length == 0 ? @"" :self.seachField.text;
        condition[@"title"]=title;
        condition[@"type"]=[self userType:self.currentRoletype];
        condition[@"page"]=@"1";
        
        HGUserListController *controller = [[HGUserListController alloc] initWithSearchCondition:condition userType:self.currentRoletype];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(NSString *)userType:(NSInteger) tag{
    NSString *result = @"";
    switch (tag) {
        case 0:
            result = @"model";
            break;
        case 1:
            result = @"editor";
            break;
        case 2:
            result = @"vip";
        default:
            break;
    }
    return result;
}

#pragma mark - Actions
-(IBAction)tappedBtn:(UIButton *)btn{
    __block UIButton *blockbtn = btn;
    __weak typeof(self) mySelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        mySelf.indicatorView.frame = CGRectMake(30+btn.tag*160, 36,100, 4);
        if (blockbtn.tag == 0) {
            mySelf.userCategoryView.alpha = 1;
            mySelf.tableView.alpha = 0;
            [mySelf.btn1 setTitleColor:kCommonHoghtedColor forState:UIControlStateNormal] ;
            [mySelf.btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            mySelf.userCategoryView.alpha = 0;
            mySelf.tableView.alpha=1;
            [mySelf.btn2 setTitleColor:kCommonHoghtedColor forState:UIControlStateNormal];
            [mySelf.btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }];
    self.currentSearchType = btn.tag;
}

-(IBAction)checkAllUsers:(UIButton *)sender{
//    UIColor *normalColor = [UIColor blackColor];
//    if (sender.tag == self.currentRoletype) {
//        self.currentRoletype = -1;
//        self.labelModel.textColor = normalColor;
//        self.labelEditor.textColor = normalColor;
//        self.labelVIP.textColor = normalColor;
//        return;
//    }else{
//    
//    switch (sender.tag) {
//        case 0:{
//            self.labelModel.textColor = kCommonHoghtedColor;
//            self.labelEditor.textColor = normalColor;
//            self.labelVIP.textColor = normalColor;
//        }
//            break;
//        case 1:{
//            self.labelModel.textColor = normalColor;
//            self.labelEditor.textColor = kCommonHoghtedColor;
//            self.labelVIP.textColor = normalColor;
//        }
//            break;
//        case 2:{
//            self.labelModel.textColor = normalColor;
//            self.labelEditor.textColor = normalColor;
//            self.labelVIP.textColor = kCommonHoghtedColor;
//        }
//            break;
//        default:
//            break;
//    }
    self.currentRoletype = sender.tag;
    NSMutableDictionary *condition = [@{} mutableCopy];
    condition[@"requesttype"] = @"searchuser";
    NSString *title =  @"";
    condition[@"title"]=title;
    condition[@"type"]=[self userType:self.currentRoletype];
    condition[@"page"]=@"1";
    
    HGUserListController *controller = [[HGUserListController alloc] initWithSearchCondition:condition userType:self.currentRoletype];
    [self.navigationController pushViewController:controller animated:YES];

//    }
}

#pragma mark - UITableView DataSource and Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchReults.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [HGAblumInfoCell cellHeight];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HGAblumInfoCell *cell = [HGAblumInfoCell cellForTableView:tableView fromNib:self.ablumInfoCellNib];
    cell.delegate = self;
    Ablum *ablum = [self.searchReults objectAtIndex:indexPath.row];
    [cell setContent:ablum withIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Ablum *ablum = self.searchReults[indexPath.row];
    
    HGAblumDetailInfoController *detailController = [[HGAblumDetailInfoController alloc] initWithType:AblumTypeSearch ablum:ablum];
    [self.navigationController pushViewController:detailController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - UISearchBar delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self hideKeyboard];
    
    [self searchWithCondition:searchBar.text];
}

#pragma mark - UItextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length>0) {
        [self hideKeyboard];
        if (self.currentSearchType == 0) {
            [self wantSearch];
        }else{
            [self searchWithCondition:textField.text];
        }
    }
    return YES;
}

#pragma mark - Private
-(HGAblumService *)ablumService{
    if (_ablumService == nil) {
        _ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _ablumService;
}

-(UINib *)ablumInfoCellNib{
    if(_ablumInfoCellNib==nil){
        _ablumInfoCellNib = [HGAblumInfoCell nib];
    }
    return _ablumInfoCellNib;
}


-(NSString *)searchType{
    return self.typeSegment.selectedSegmentIndex == 0  ? @"平面" : @"T台";
}


-(void)searchWithCondition:(NSString *)condition{
    if (self.searchReults) {
        [self.searchReults removeAllObjects];
        [self.tableView reloadData];
    }
    [self loading];
    NSADictionary *dict = [@{@"requesttype":@"search",
                             @"titile": condition,
                            @"type":[self searchType]} copy];
    __weak typeof(self) mySelf = self;
    [self.ablumService searchAblumWithSearchCondition:dict Successed:^(MKNetworkOperation *completedOperation, id result) {
        [mySelf successedWitnMessage:nil];
        mySelf.searchReults = [result mutableCopy];
        if (mySelf.searchReults.count>0) {
            [mySelf.tableView reloadData];
        }else{
            [mySelf failedWithMessageNotification:@"很遗憾，没有找到合适的搜索结果"];
//            [UIAlertView showWithTitle:nil message:@"很遗憾，没有找到合适的搜索结果，是否看下我们的最新推荐？" cancelButtonTitle:@"不感兴趣" otherButtonTitles:@[@"马上查看"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                if (buttonIndex==1) {
//                    [mySelf.mm_drawerController setCenterViewController:[AppDelegate newsAblumListController] withFullCloseAnimation:YES completion:nil];
//                }
//            }];
        }
    } error:^(NSError *error) {
        [mySelf failedWithMessage:@"搜索失败，请稍后重试" conmpleted:nil];
    }];
}


#pragma mark - UIScrollview delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideKeyboard];
}

#pragma mark - AblumInfoCell Delegate
#pragma mark - HGAblumInfoCell Delegate
-(void)ablumInfoCell:(HGAblumInfoCell *)cell didClickeButton:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"立刻阅读"]) {
        Ablum *ablum = self.searchReults[btn.tag];
        self.currentId = ablum.ablumid;
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
        
        __block HGAblumInfoCell *blockCell = cell;
        __block Ablum *ablum = self.searchReults[btn.tag];
        __weak typeof(self) mySelf = self;
        NSString *pathToStore = [[[HGSandboxHelper sharedInstance] getAppTmpDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"ablum%@.zip",ablum.ablumid]];
        
        __weak UIButton *blockBtn = btn;
        
        [self.ablumService downloadAblumWithId:ablum.ablumid toFile:pathToStore progress:^(double progress) {
            [blockCell.downloadIndicator setProgress:progress animated:YES];
        } Successed:^(MKNetworkOperation *completedOperation, id result) {
            DLog(@"download success");
            [[HGLocalAblumsManager sharedInstance] addDownloadedAblum:ablum.ablumid];
            [[HGLocalAblumsManager sharedInstance] unZipAblum:ablum.ablumid fromTmpFilePath:result];
            NSData *data = UIImageJPEGRepresentation(blockCell.coverImgView.image, 1.0);
            [[HGLocalAblumsManager sharedInstance] addCoverImage:data forAblum:ablum.ablumid];
            
            blockCell.downloadIndicator.progress = 1;
            [UIView animateWithDuration:0.2 animations:^{
                blockCell.indicatorContainerView.hidden = YES;
            } completion:^(BOOL finished) {
                [blockBtn setTitle:@"立刻阅读" forState:UIControlStateNormal];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:blockBtn.tag inSection:0];
                [mySelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
            [mySelf successedWitnMessage:nil];
        } error:^(NSError *error) {
            [mySelf failedWithMessage:@"下载专辑失败，请稍后重试！" conmpleted:nil];
            blockCell.indicatorContainerView.hidden = YES;
        }];
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
    __block Ablum *currentAblum = self.searchReults[self.selectedIndex];
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



@end
