//
//  HGEditAblumController.m
//  modelbase
//
//  Created by HamGuy on 5/23/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGEditAblumController.h"
#import "HGPopContainerView.h"
#import "HGAblumCell.h"
#import "Cover.h"
#import "Ablum.h"
#import "HGAblumService.h"
#import "UIImageView+Loading.h"
#import "MBProgressHUD.h"
#import "UIImage+Resize.h"
#import "QBImagePickerController.h"
#import "HGAddAblumCellTableViewCell.h"
#import "HGExtendImageView.h"
#import "HGLocalAblumsManager.h"
#import "HGSandboxHelper.h"
#import "Note.h"
#import "UIImage+WaterMark.h"
#import "HGUploadManager.h"
#import "HGSavefileTask.h"
#import "UIImage+ResizeMagic.h"
#import "UIImage+FixOrientation.h"


#define kThumbnailWidthAndHeight 75.f
#define kThunmbailInset 10.f
#define kMaxAllowCout 8

@interface HGEditAblumController ()<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate,QBImagePickerControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *layout1;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *coverImgView;

@property (nonatomic, strong) UIViewController *leftViewController;

//note
@property (nonatomic, strong) IBOutlet UIView *editNoteContainerView;
@property (nonatomic, weak) IBOutlet UITextField *noteField;

//editcover
@property (nonatomic, strong) IBOutlet UIView *editCoverContainerView;

//upload
@property (nonatomic, weak) IBOutlet UIButton *addPicBtn;
@property (nonatomic, weak) IBOutlet UIScrollView *picContainerView;
@property (nonatomic, strong) NSMutableArray *imageAsserts;

@property (nonatomic, strong) IBOutlet UIView *addPhotoContainerView;

@property(nonatomic, strong) HGAblumCell *currentCell;
@property (nonatomic, strong) HGAblumService *ablumService;
@property (nonatomic, strong) Cover *currentCover;
@property (nonatomic, strong) Ablum *currentAblum;

@property (nonatomic, strong) HGExtendImageView *targetImageView;

@property (nonatomic, strong) NSArray *allPics;
@property (nonatomic, strong) NSArray *allThums;
@property (nonatomic, strong) NSMutableArray *allNotes;


@property (nonatomic, strong) UIImage *tmpImage;
@property (nonatomic, assign) BOOL needUpdateCover;
@property (nonatomic, strong) HGSandboxHelper *sandBoxHelper;
@property (nonatomic, strong) NSMutableArray *picToUpload;
@property (nonatomic, assign) BOOL shouldCanel;
@property (nonatomic, strong) ALAssetsLibrary *assertLib;
@property (nonatomic, strong) QBImagePickerController *imgPickerController;

@property (nonatomic, strong) MBProgressHUD *iploadHUD;

@property (nonatomic, strong) HGUploadManager *uploadManager;

@end

@implementation HGEditAblumController

- (id)initWithCover:(Ablum *)ablum
{
    self = [super initWithNibName:@"HGEditAblumController" bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"编辑专辑";
        self.currentAblum = ablum;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"编辑专辑";
    // Do any additional setup after loading the view from its nib.
    [self addbackButtonWithAction:@selector(goBack)];
    [self addRightButtonWithImage:[UIImage imageNamed:@"IconUpload"] highlight:[UIImage imageNamed:@"IconUploadPress"] action:@selector(uploadPhoto)];
    
    [self.collectionView registerClass:[HGAblumCell class] forCellWithReuseIdentifier:@"editAblumCell"];
    [self.collectionView registerNib:[HGAblumCell nib] forCellWithReuseIdentifier:@"editAblumCell"];
    
    
    [self.noteField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.editNoteContainerView.layer.cornerRadius = 2.f;
    self.editCoverContainerView.layer.cornerRadius = 2.f;
    self.addPhotoContainerView.layer.cornerRadius = 4.f;
    
    self.imageAsserts = [@[] mutableCopy];
    self.allPics = [@[] copy];
    self.allNotes = [[Note allNotesIn:self.currentAblum.ablumid] mutableCopy];
    
    [self setUpInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.leftViewController = self.mm_drawerController.leftDrawerViewController;
    [self.mm_drawerController setLeftDrawerViewController:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setLeftDrawerViewController:self.leftViewController];
}


-(HGAblumService *)ablumService{
    if(_ablumService == nil){
        _ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _ablumService;
}

-(HGSandboxHelper *)sandBoxHelper{
    if (_sandBoxHelper == nil) {
        _sandBoxHelper = [HGSandboxHelper sharedInstance];
    }
    return _sandBoxHelper;
}

-(NSArray *)allPics{
    if (_allPics == nil) {
        _allPics = [[HGLocalAblumsManager sharedInstance] allLocalPicsOfAblum:self.currentAblum.ablumid];
    }
    return _allPics;
}

-(NSArray *)allThums{
    if (_allThums== nil) {
        _allThums = [[HGLocalAblumsManager sharedInstance] allLocThumsOfAblum:self.currentAblum.ablumid];
    }
    return _allThums;
}

-(NSArray *)allNotes{
    if (_allNotes == nil) {
        _allNotes = nil;
    }
    return _allNotes;
}

-(QBImagePickerController *)imgPickerController{
    if (_imgPickerController == nil) {
        _imgPickerController = [[QBImagePickerController alloc] init];
        _imgPickerController.delegate = self;
        _imgPickerController.view.tag = 1;
        _imgPickerController.allowsMultipleSelection = YES;
        _imgPickerController.maximumNumberOfSelection = kMaxAllowCout;
    }
    return _imgPickerController;
}

-(HGUploadManager *)uploadManager{
    if (_uploadManager == nil) {
        _uploadManager = [[HGUploadManager alloc] init];
    }
    return _uploadManager;
}

-(void)dealloc{
    [self.ablumService cancelAllOperations];
    self.ablumService = nil;
    [self.uploadManager cancelAllOperations];
    self.uploadManager = nil;
    self.imgPickerController = nil;
}

#pragma mark - Actions
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)uploadPhoto{
    [HGPopContainerView showInparetView:[self rootVC].view WithView:self.addPhotoContainerView animtionDuration:0.5f TapToDismiss:YES];
}

-(IBAction)confirmUpload:(id)sender{
    if (self.imageAsserts.count==0) {
        [UIAlertView showNoticeWithTitle:nil message:@"您尚未添加图片！" cancelButtonTitle:@"确定"];
        return;
    }
    
    [HGPopContainerView dismiss];
    
    
    
    if (![[HGSandboxHelper sharedInstance] isDirectoryExist:[NSString stringWithFormat:@"%@/%@",kFileToUplaodDirectoryName,self.currentAblum.ablumid]]) {
        [[HGSandboxHelper sharedInstance] createDirectory:[NSString stringWithFormat:@"%@/%@",kFileToUplaodDirectoryName,self.currentAblum.ablumid]];
    }
    
    if (![[HGSandboxHelper sharedInstance] isDirectoryExist:[NSString stringWithFormat:@"%@/%@",kFileToUploadThumDirectry,self.currentAblum.ablumid]]) {
        [[HGSandboxHelper sharedInstance] createDirectory:[NSString stringWithFormat:@"%@/%@",kFileToUploadThumDirectry,self.currentAblum.ablumid]];
    }
    
    
    self.picToUpload = [@[] mutableCopy];
    __weak typeof(self) mySelf = self;
    
    __block NSInteger picCopunt = self.allPics.count;
    dispatch_queue_t queue = dispatch_queue_create("com.hamguy.modelbase.upload", 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    __block CGImageRef fullImageRef;
    __block CGImageRef thumImageRef;
    dispatch_async(dispatch_get_main_queue(), ^{
        [mySelf loadingWithMsg:@"正在保存照片"];
        [mySelf loading];
    });
    for (NSInteger idx = 0;idx<self.imageAsserts.count;idx++) {
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(queue, ^{
            @autoreleasepool {//
                NSString *imgFileName = [NSString stringWithFormat:@"%03lu.jpg",(unsigned long)idx+picCopunt+1];
                NSString *acturlFileName = [[mySelf.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUplaodDirectoryName,mySelf.currentAblum.ablumid,imgFileName]];
                NSString *acturlThumFileName = [[mySelf.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUploadThumDirectry,mySelf.currentAblum.ablumid,imgFileName]];
                
                
                ALAsset *asset = mySelf.imageAsserts[idx];
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                
                DLog(@"filename ===== %@",imgFileName);
                fullImageRef = [rep fullResolutionImage];
                CGImageRef fullScreenRef = [rep fullScreenImage];
                rep = nil;
                //保存缩略图
                thumImageRef = [mySelf resizeCGImage:fullScreenRef toWidth:240 andHeight:180];
                
                UIImage *thumImage  = [UIImage imageWithCGImage:thumImageRef];
                [thumImage fixOrientation];
                NSData *thumImageData = UIImageJPEGRepresentation(thumImage, 0.8);
                thumImage = nil;
                [mySelf.sandBoxHelper createFile:acturlThumFileName withData:thumImageData];
                DLog(@"thumbinal process completed! ### %@",imgFileName);
                
                thumImageData = nil; //释放内存
                
                UIImage *fullImage = [UIImage imageWithCGImage:fullImageRef];
                int fullImageWidth = fullImage.size.width;
                int fullImageHeight = fullImage.size.height;
                UIImage *resizedImage = nil;
                if (fullImageWidth>fullImageHeight) {
                    if (fullImageWidth>2048 && fullImageHeight>1536) {
                        resizedImage = [fullImage resizedImageWithMaximumSize:CGSizeMake(2048, 1536)];
                    }
                }else {
                    if (fullImageHeight> 2048 && fullImageWidth>1536) {
                        resizedImage = [fullImage resizedImageWithMaximumSize:CGSizeMake(1536, 2048)];
                    }
                }
                [resizedImage fixOrientation];
                UIImage *maskImage = [UIImage imageNamed:@"BgWatermark"];
                UIImage *maskedImage = [self image:resizedImage ? : fullImage withWaterMask:maskImage];
                maskImage = nil;
                fullImage = nil;
                NSData *fullImageData = UIImageJPEGRepresentation(maskedImage, 0.8);
                [mySelf.sandBoxHelper createFile:acturlFileName withData:fullImageData];
                fullImageData = nil;
                [mySelf.picToUpload addObject:imgFileName];
                dispatch_semaphore_signal(semaphore);
            }
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, queue,^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [mySelf uploadImage];
            DLog(@"file save completed!");
        });
    });
    
}

-(void)uploadImage{
    __weak typeof(self) mySelf = self;
    [self loadingWithMsg:@"正在上传图片" progress:0];
    [self.picToUpload enumerateObjectsUsingBlock:^(NSString* file, NSUInteger idx, BOOL *stop) {
        NSInteger picCopunt = self.allPics.count;
        NSMutableDictionary *dict = [@{} mutableCopy];
        dict[@"requesttype"]=@"uploadimage";
        dict[@"id"]=mySelf.currentAblum.ablumid;
        dict[@"image"]=[NSString stringWithFormat:@"%lu",(unsigned long)idx+picCopunt+1];
        [mySelf.uploadManager addRequestWithInfo:dict file:file tag:idx];
    }];
    [self.uploadManager startploadOperationWithProigress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [mySelf loadingWithMsg:@"正在上传图片" progress:progress];
            
        });
    } completedBlock:^(BOOL success, NSError *error) {
        if (error == nil) {
            [mySelf successedWitnMessage:@"图片上传成功"];
        }else{
            
            [mySelf failedWithMessageNotification:@"上传失败，请稍后重试！"];

            [mySelf deleteFailedFile:error.code];
        }
        [mySelf setUpPhotos];
    }];
}

-(void)deleteFailedFile:(NSInteger)fromIndex{
    for (NSInteger i = (fromIndex -1); i<self.picToUpload.count; i++) {
        NSString *imgFileName = self.picToUpload[i];
        NSString *acturlFileName = [[self.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUplaodDirectoryName,self.currentAblum.ablumid,imgFileName]];
        [self.sandBoxHelper deleteFile:acturlFileName];//删除大图
        NSString *acturlThumFileName = [[self.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUploadThumDirectry,self.currentAblum.ablumid,imgFileName]];
        [self.sandBoxHelper deleteFile:acturlThumFileName];//删除缩略图
    }
}


-(IBAction)changeCover:(id)sender{
    self.tmpImage = self.coverImgView.image;
    self.needUpdateCover = NO;
    [HGPopContainerView showInparetView:[self rootVC].view WithView:self.editCoverContainerView animtionDuration:0.5f TapToDismiss:YES];
}

-(IBAction)changeNotes:(NSIndexPath *)indexPath{
    self.currentCell = (HGAblumCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (self.currentCell.titleLabel.text.length>0) {
        self.noteField.text = self.currentCell.titleLabel.text;
    }
    [HGPopContainerView showInparetView:[self rootVC].view WithView:self.editNoteContainerView animtionDuration:0.5f TapToDismiss:YES];
    [HGPopContainerView changeSubViewTop:-60];
}

#pragma mark - Private

-(void)setUpInfo{
    self.titleLabel.text = self.currentAblum.title;// ? : @"Test";
    __weak typeof(self) mySelf = self;
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kCoverUrl,self.currentAblum.path];
    [self.coverImgView setImageShowingActivityIndicatorWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"BgPlaceHoderSmall"] failed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            mySelf.coverImgView.image = [UIImage imageNamed:@"BgImageFiledSmall"];
        });
    }];
    self.descriptionLabel.text = mySelf.currentAblum.abdescription;
    [self setUpPhotos];
}

-(void)setUpPhotos{
    self.allThums = nil;
    self.allPics = [[HGLocalAblumsManager sharedInstance] allLocalPicsOfAblum:self.currentAblum.ablumid];
    [self.collectionView reloadData];
}

#pragma mark - CollectionView Data Source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.allPics.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HGAblumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"editAblumCell" forIndexPath:indexPath];
    if (self.allPics.count>0) {
        __block NSString *picName = [self.allThums objectAtIndex:indexPath.row];
        picName = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:picName];
        __block UIImage *img = nil;
        cell.imageView.image = [UIImage imageNamed:@"Covertest"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            img = [UIImage imageWithContentsOfFile:picName];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = img;
            });
        });
        
        if (self.allNotes.count>0) {
            Note *note = [Note noteAtIndex:indexPath.row];
            if (note) {
                cell.titleLabel.text =note.noteinfo;
            }
            
        }
    }
    //    cell.titleLabel.text = @"测试测试";
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self changeNotes:indexPath];
    
}

#pragma mark - Edit Note
-(IBAction)confirmNoteChange:(id)sender{
    if (self.noteField.text.length>0) {
        NSIndexPath *indexpath =[self.collectionView indexPathForCell:self.currentCell];
        Note *note = [Note noteAtIndex:indexpath.row];
        if (note == nil) {
            note = [Note MR_createEntity];
            note.index =[NSNumber numberWithInt:indexpath.row];
            note.ablumid = self.currentAblum.ablumid;
        }
        note.noteinfo = self.noteField.text;
        self.currentCell.titleLabel.text = self.noteField.text;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    [HGPopContainerView dismiss];
}


-(IBAction)deletePic:(id)sender{
    __block NSIndexPath *indexpath =[self.collectionView indexPathForCell:self.currentCell];
    __weak typeof(self)mySelf = self;
    NSString *imgName = [NSString stringWithFormat:@"%d.jpg",indexpath.row+1];
    
    [self.ablumService delePhoto:imgName fromAblum:self.currentAblum.ablumid Successed:^(MKNetworkOperation *completedOperation, id result) {
        [mySelf.collectionView deleteItemsAtIndexPaths:@[indexpath]];
        if (mySelf.noteField.text.length>0) {
            Note *note = [Note noteAtIndex:indexpath.row];
            [note MR_deleteEntity];
        }
        [mySelf successedWitnMessage:@"删除图片成功"];
    } error:^(NSError *error) {
        [mySelf failedWithMessageNotification:@"删除图片失败"];
    }];
    [HGPopContainerView dismiss];
}

#pragma mark - Edit Cover
-(IBAction)chooseFromAblum:(id)sender{
    if ([QBImagePickerController isAccessible]) {
        QBImagePickerController *controller = [[QBImagePickerController alloc] init];
        controller.delegate = self;
        controller.view.tag = 0;
        HGNavigationController *nav = [[HGNavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

-(IBAction)takePhoto:(id)sender{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.allowsEditing = YES;
        [self presentViewController:controller animated:YES completion:nil];
        controller=nil;
    }
    
}

-(IBAction)editCoverDone:(id)sender{
    [HGPopContainerView dismiss];
    if (!self.needUpdateCover) {
        return;
    }
    
    [self loading];
    
    @autoreleasepool {
        NSString *dirName =[NSString stringWithFormat:@"%@/%@",kLocalCoverDirectoryName,self.currentAblum.ablumid];
        if (![[HGSandboxHelper sharedInstance] isDirectoryExist:dirName]) {
            [[HGSandboxHelper sharedInstance] createDirectory:dirName];
        }
        
        NSData *data = UIImageJPEGRepresentation(self.coverImgView.image, 0.5);
        NSString *coverPath = [[self.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",dirName]];
        [[HGSandboxHelper sharedInstance] createFile:coverPath withData:data];
        
        NSMutableDictionary *dict = [@{} mutableCopy];
        dict[@"requesttype"]=@"uploadimage";
        dict[@"id"]=self.currentAblum.ablumid;
        dict[@"image"]=@"cover";
        
        __weak typeof(self) mySelf = self;
        
        [self.uploadManager sigleRequestWithInfo:dict file:coverPath withProigress:^(CGFloat progress) {
            [mySelf loadingWithMsg:@"正在上传封面" progress:progress];
        } completedBlock:^(BOOL success, NSError *error) {
            if (error == nil) {
                [mySelf successedWitnMessage:@"修改封面成功"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMyListNotification object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil];
            }else{
                [mySelf failedWithMessage:@"修改封面失败，请稍后重试！" conmpleted:nil];
            }
        }];
        //        [self.ablumService uploadImage:dict file:coverPath progress:^(double progress) {
        ////            [mySelf loadingWithMsg:@"正在上传封面" progress:progress];
        //        } Successed:^(MKNetworkOperation *completedOperation, id result) {
        //            [mySelf successedWitnMessage:@"修改封面成功"];
        //        } error:^(NSError *error) {
        //            [mySelf failedWithMessage:@"修改封面失败，请稍后重试！" conmpleted:nil];
        //        }];
    }
}

-(IBAction)editCoverCancel:(id)sender{
    self.coverImgView.image = self.tmpImage ;
    self.tmpImage = nil;
    [HGPopContainerView dismiss];
}

#pragma mark - AddPhoto
-(IBAction)addPhotos:(UIButton *)btn{
    //移动添加按钮
    [self.picContainerView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    if ([QBImagePickerController isAccessible]) {
        HGNavigationController *nav = [[HGNavigationController alloc] initWithRootViewController:self.imgPickerController];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

#pragma mark - QBImagePickerController delegate
-(void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset{
    [imagePickerController loading];
    __block CGImageRef imgRef = [asset aspectRatioThumbnail];
    __block UIImage *img = [UIImage imageWithCGImage:imgRef];
    if (imagePickerController.view.tag == 0) {
        // set cover
        self.coverImgView.image = [img resizedImage:CGSizeMake(180, 240) interpolationQuality:kCGInterpolationDefault];
        self.needUpdateCover = YES;
        [imagePickerController successedWitnMessage:nil];
    }else{
        //        NSURL *url = [[asset defaultRepresentation] url];
        
        if (![self.imageAsserts containsObject:asset]) {
            [self.imageAsserts addObject:asset];
        }
        [self addChosenPicturesView:self.imageAsserts];
    }
    [imagePickerController dismissViewControllerAnimated:YES completion:^{    }];
}

-(void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    __weak typeof(self) mySelf = self;
    [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
        //        NSURL *url = [[asset defaultRepresentation] url];
        
        if (![mySelf.imageAsserts containsObject:asset]) {
            [mySelf.imageAsserts addObject:asset];
        }
    }];
    [self addChosenPicturesView:self.imageAsserts];
    [imagePickerController dismissViewControllerAnimated:YES completion:^{    }];
    
}

- (void)imagePickerControllerDidCanceled:(QBImagePickerController *)imagePickerController{
    [imagePickerController dismissViewControllerAnimated:YES completion:^{    }];
}

#pragma mark - UImagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *img= [info objectForKey:UIImagePickerControllerEditedImage];
        self.coverImgView.image = img;
        self.needUpdateCover = YES;
        //        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        //        __weak typeof(self) mySelf = self;
        //        [library writeImageToSavedPhotosAlbum:img.CGImage
        //                                     metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
        //                              completionBlock:^(NSURL *assetURL, NSError *error) {
        //
        //                                  [mySelf.asserts addObject:assetURL];
        //                                  [mySelf addChosenPicturesView:mySelf.asserts];
        //                              }];;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(UIViewController *)rootVC{
    UIViewController *rootviewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(rootviewController.presentedViewController!=nil)
        rootviewController = rootviewController.presentedViewController;
    return rootviewController;
}


- (void)updateChosenPicturesViewPosition
{
    //    _picContainerView.hidden = [self numberOfChosenPictures] == 0;
    _addPicBtn.hidden = [self numberOfChosenPictures] == kMaxAllowCout;
    
    CGSize contentSize = CGSizeMake(75*([self numberOfChosenPictures]+1)+10*([self numberOfChosenPictures]),75);
    self.picContainerView.contentSize = contentSize;
    
    [self.picContainerView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        CGRect frame = subview.frame;
        frame.origin.x = 10 + 85 * (subview == self.addPicBtn ? [self numberOfChosenPictures] : idx - 1);
        [UIView animateWithDuration:0.2 animations:^{
            subview.frame = frame;
        }];
    }];
}

- (void)addChosenPicturesView:(NSArray *)images
{
    NSInteger index = [self numberOfChosenPictures];
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HGExtendImageView *imageView = [[HGExtendImageView alloc] initWithFrame:CGRectMake(10 + 85 * (idx + index), 0, 75, 75)];
        imageView.imageData = obj;
        imageView.userInteractionEnabled = YES;
        [self.picContainerView addSubview:imageView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImageViewTapped:)];
        [imageView addGestureRecognizer:gesture];
    }];
    
    _picContainerView.hidden = [self numberOfChosenPictures] == 0;
    _addPicBtn.hidden = [self numberOfChosenPictures] == 5;
    CGRect frame = _addPicBtn.frame;
    frame.origin.x = 10 + 85 * [self numberOfChosenPictures];
    _addPicBtn.frame = frame;
    
    self.picContainerView.contentSize = CGSizeMake(_addPicBtn.right+10, _addPicBtn.height);
    if (self.imageAsserts.count>=3) {
        [self.picContainerView setContentOffset:CGPointMake(_addPicBtn.left-170, 0) animated:YES];
    }
}

- (NSInteger)numberOfChosenPictures
{
    return self.picContainerView.subviews.count - 1;
}

- (void)postImageViewTapped:(UIGestureRecognizer *)gesture
{
    self.targetImageView = (HGExtendImageView *)gesture.view;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片操作"
                                                             delegate:self
                                                    cancelButtonTitle:@"返回"
                                               destructiveButtonTitle:@"清除图片"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        return;
    }
    
    [self.imageAsserts removeObject:_targetImageView.imageData];
    [_targetImageView removeFromSuperview];
    [self updateChosenPicturesViewPosition];
}

- (CGImageRef)resizeCGImage:(CGImageRef)image toWidth:(int)width andHeight:(int)height {
    // create context, keeping original image properties
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    CGContextRef context = CGBitmapContextCreate(NULL, width, height,
                                                 CGImageGetBitsPerComponent(image),
                                                 CGImageGetBytesPerRow(image),
                                                 colorspace,
                                                 CGImageGetBitmapInfo(image));
    CGColorSpaceRelease(colorspace);
    
    if(context == NULL)
        return nil;
    
    // draw image to context (resizing it)
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    // extract resulting image from context
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return imgRef;
}


- (UIImage *) image:(UIImage *)originalImage withWaterMask:(UIImage*)mask
{
    int maskWidth = originalImage.size.width/10;
    int maskHeight = originalImage.size.height/10;
    
    if (maskWidth>=mask.size.width && maskHeight >mask.size.height) {
        maskWidth = mask.size.width;
        maskHeight = mask.size.height;
    }
    
    CGImageRef maskRef = [mask CGImage];
    CGImageRef resizeMask = [self resizeCGImage:maskRef toWidth:maskWidth andHeight:maskHeight];
    //    CGImageRelease(maskRef);
    //    mask = nil;
    UIImage *newMaskImage = [UIImage imageWithCGImage:resizeMask];
    //    CGImageRelease(resizeMask);
    
    CGRect rect = CGRectMake(originalImage.size.width - maskWidth, originalImage.size.height-maskHeight, maskWidth, maskHeight);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions([originalImage size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    
    //
    [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    //
    [newMaskImage drawInRect:rect];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}
@end
