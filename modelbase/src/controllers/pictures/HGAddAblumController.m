//
//  HGAddAblumController.m
//  modelbase
//
//  Created by HamGuy on 6/1/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAddAblumController.h"
#import "HGCurretUserContext.h"
#import "Ablum.h"
#import "HGAblumService.h"
#import "HGSandboxHelper.h"
#import <MKNetworkKit/Categories/NSDictionary+RequestEncoding.h>
#import <ZipArchive/ZipArchive.h>
#import "QBImagePickerController.h"
#import "UIImage+WaterMark.h"
#import "UIImage+ResizeMagic.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HGAddAblumCellTableViewCell.h"
#import "HGAblumService.h"
#import "HGLocalAblumsManager.h"
#import "HGUploadManager.h"
#import "UIImage+FixOrientation.h"

#define kMaxCountOfPics 9.0

@interface HGAddAblumController ()<QBImagePickerControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate,HGAddAblumCellTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSString *coverImageName;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) NSMutableDictionary *ablumInfo;
@property (nonatomic, strong) NSMutableArray *picToUpload;
@property (nonatomic, strong) NSMutableArray *imageAsserts;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) HGSandboxHelper *sandBoxHelper;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollContainer;
@property (nonatomic, strong) HGAblumService *ablumService;
@property (nonatomic, assign) NSInteger coverInedx;
@property (nonatomic, weak) IBOutlet UIButton *takeImageBtn;
@property (nonatomic, weak) IBOutlet UIButton *choosePicBtn;
@property (nonatomic, strong) NSString *currentAblumId;
@property (nonatomic, strong) NSMutableArray *thumList;

@property (nonatomic, assign) __block BOOL shouldCanel;

@property (nonatomic, strong) HGUploadManager *uploadManager;


@end

@implementation HGAddAblumController

- (id)init
{
    self = [super initWithNibName:@"HGAddAblumController" bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"上传专辑";
        self.imageAsserts = [@[] mutableCopy];
        self.coverInedx = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addbackButtonWithAction:@selector(goBack)];
    [self addRightBarButtonWithName:@"确认" withAction:@selector(confirmUpload)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.shouldCanel = NO;
    self.sandBoxHelper = [HGSandboxHelper sharedInstance];
    [self configCollectionView];
    if (!is_iPhone5) {
        self.scrollContainer.scrollEnabled = YES;
        self.scrollContainer.contentSize = CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT+20);
        
    }}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.leftViewController = self.mm_drawerController.leftDrawerViewController;
    [self.mm_drawerController setLeftDrawerViewController:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setLeftDrawerViewController:self.leftViewController];
    self.shouldCanel = YES;
}

-(HGAblumService *)ablumService{
    if (_ablumService == nil) {
        _ablumService = [[HGAblumService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _ablumService;
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
}

#pragma mark - Actions
-(void)hideKeyboard{
    [self.textView resignFirstResponder];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirmUpload{

    [self hideKeyboard];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;

    if (self.nameField.text.length>0 && self.textView.text.length>0) {
        //压缩得到文件名
        [self loading];
        
        if (self.coverImageName == nil || self.coverImageName.length == 0) {
            self.coverImageName = @"001.jpg";
        }
        
        self.ablumInfo = [@{} mutableCopy];
        _ablumInfo[@"requesttype"]=@"upload";
        _ablumInfo[@"title"]=self.nameField.text;
        _ablumInfo[@"description"]= self.textView.text;
        _ablumInfo[@"cover"]= self.coverImageName;
        
        __weak typeof(self) mySelf = self;
        [self.ablumService createAblum:self.ablumInfo Successed:^(MKNetworkOperation *completedOperation, id result) {
            NSDictionary *dict = result;
            mySelf.currentAblumId = [dict objectForKey:@"id"];
            
            [[HGLocalAblumsManager sharedInstance] addCoverTitle:mySelf.nameField.text forAblum:mySelf.currentAblumId];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil];
            [mySelf.ablumService cancelAllOperations];
            [mySelf archivePicturesToSandBox];
                DLog(@"file save completed!");
            DLog("success")
        } error:^(NSError *error) {
            [mySelf failedWithMessage:@"创建专辑失败！" conmpleted:nil];
        }];
        
        [self successedWitnMessage:nil];
    }else{
        [UIAlertView showNoticeWithTitle:nil message:@"专辑名或描述不能为空！" cancelButtonTitle:@"确定"];
    }
}

-(IBAction)takePhoto:(id)sender{
    [self hideKeyboard];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.allowsEditing = NO;
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(IBAction)choosePhotos:(id)sender{
    [self hideKeyboard];
    if ([QBImagePickerController isAccessible]) {
        QBImagePickerController *controller = [[QBImagePickerController alloc] init];
        HGNavigationController *nav = [[HGNavigationController alloc] initWithRootViewController:controller];
        controller.delegate = self;
        controller.view.tag = 1;
        controller.allowsMultipleSelection = YES;
        controller.minimumNumberOfSelection = 1;
        controller.maximumNumberOfSelection=kMaxCountOfPics;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Private
-(void)configCollectionView{
    self.collectionView.allowsSelection = YES;
    [self.collectionView registerClass:[HGAddAblumCellTableViewCell class] forCellWithReuseIdentifier:@"addCell"];
    [self.collectionView registerNib:[HGAddAblumCellTableViewCell nib] forCellWithReuseIdentifier:@"addCell"];
}

-(void)archivePicturesToSandBox{
    
    if (self.imageAsserts.count==0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMyListNotification object:nil];
        [self successedWitnMessage:@"创建专辑成功！"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    if (![[HGSandboxHelper sharedInstance] isDirectoryExist:[NSString stringWithFormat:@"%@/%@",kFileToUplaodDirectoryName,self.currentAblumId]]) {
        [[HGSandboxHelper sharedInstance] createDirectory:[NSString stringWithFormat:@"%@/%@",kFileToUplaodDirectoryName,self.currentAblumId]];
    }
    
    if (![[HGSandboxHelper sharedInstance] isDirectoryExist:[NSString stringWithFormat:@"%@/%@",kFileToUploadThumDirectry,self.currentAblumId]]) {
        [[HGSandboxHelper sharedInstance] createDirectory:[NSString stringWithFormat:@"%@/%@",kFileToUploadThumDirectry,self.currentAblumId]];
    }
    
    self.picToUpload = [@[] mutableCopy];
    __weak typeof(self) mySelf = self;
    
    dispatch_queue_t queue = dispatch_queue_create("com.hamguy.modelbase.upload", 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    __block CGImageRef fullImageRef;
    __block CGImageRef thumImageRef;
    dispatch_async(dispatch_get_main_queue(), ^{
//        [mySelf loadingWithMsg:@"正在保存照片"];
        [mySelf loading];
    });
    for (NSInteger idx = 0;idx<self.imageAsserts.count;idx++) {
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(queue, ^{
            @autoreleasepool {//
                NSString *imgFileName = [NSString stringWithFormat:@"%03lu.jpg",(unsigned long)idx+1];
                NSString *acturlFileName = [[mySelf.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUplaodDirectoryName,mySelf.currentAblumId,imgFileName]];
                NSString *acturlThumFileName = [[mySelf.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUploadThumDirectry,mySelf.currentAblumId,imgFileName]];
                
                
                ALAsset *asset = mySelf.imageAsserts[idx];
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                
                DLog(@"filename ===== %@",imgFileName);
                fullImageRef = [rep fullResolutionImage];
                CGImageRef fullScreenRef = [rep fullScreenImage];
                rep = nil;
                //保存缩略图
                thumImageRef = [mySelf resizeCGImage:fullScreenRef toWidth:180 andHeight:240];
                
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
                DLog(@"full image process completed! ### %@",imgFileName);
                }
                dispatch_semaphore_signal(semaphore);
            
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, queue,^{
        [mySelf uploadImage];
    });
}

-(void)uploadImage{
    __weak typeof(self) mySelf = self;
    
    NSDictionary *coverDict = @{@"requesttype":@"uploadimage",
                                @"id":self.currentAblumId,
                                @"image":@"cover"};
    [mySelf.uploadManager addRequestWithInfo:coverDict file:self.coverImageName tag:0];

    [self.picToUpload enumerateObjectsUsingBlock:^(NSString* file, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = [@{} mutableCopy];
        dict[@"requesttype"]=@"uploadimage";
        dict[@"id"]=mySelf.currentAblumId;
        dict[@"image"]=[NSString stringWithFormat:@"%lu",(unsigned long)idx+1];
        [mySelf.uploadManager addRequestWithInfo:dict file:file tag:idx];
    }];
    
    [self.uploadManager startploadOperationWithProigress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [mySelf loadingWithMsg:@"正在上传图片，请不要离开本页面" progress:progress];
        });
        
    } completedBlock:^(BOOL success, NSError *error) {
        if (error == nil) {
            [mySelf successedWitnMessage:@"图片上传成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMyListNotification object:nil];

            [mySelf.navigationController popViewControllerAnimated:YES];
        }else{
            [mySelf failedWithMessageNotification:@"上传失败，请稍后重试！"];
//            [mySelf failedWithMessage: conmpleted:nil];
            [mySelf deleteFailedFile:error.code];
        }
    }];
    

}

-(void)deleteFailedFile:(NSInteger)fromIndex{
    for (NSInteger i = (fromIndex -1); i<self.picToUpload.count; i++) {
        NSString *imgFileName = self.picToUpload[i];
        NSString *acturlFileName = [[self.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUplaodDirectoryName,self.currentAblumId,imgFileName]];
        [self.sandBoxHelper deleteFile:acturlFileName];//删除大图
        NSString *acturlThumFileName = [[self.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUploadThumDirectry,self.currentAblumId,imgFileName]];
        [self.sandBoxHelper deleteFile:acturlThumFileName];//删除缩略图
    }
}

-(NSString *)currentTime{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

#pragma mark - QBImagePickerControllerDelegate

-(void)imagePickerController:(QBImagePickerController *)imagePickerController
             didSelectAssets:(NSArray *)assets{
    if (assets) {
        [self.imageAsserts addObjectsFromArray:assets];
    }
    [self.collectionView reloadData];
    if (self.currentIndexPath == nil) {
        [self setupCover:0];
    }
    [self updateButtonState];
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCanceled:(QBImagePickerController *)imagePickerController{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *img= [info objectForKey:UIImagePickerControllerOriginalImage];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        __weak typeof(self) mySelf = self;
        [library writeImageToSavedPhotosAlbum:img.CGImage
                                     metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  
                                  [mySelf.imageAsserts addObject:assetURL];
                                  [mySelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:mySelf.imageAsserts.count-1 inSection:0]]];
                                  [mySelf updateButtonState];
                              }];;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
    if (buttonIndex == 0) {
        HGAddAblumCellTableViewCell *cell = (HGAddAblumCellTableViewCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
        [self.imageAsserts removeObject:cell.imageData];
        [self.collectionView deleteItemsAtIndexPaths:@[self.currentIndexPath]];
        [self.collectionView reloadData];
    }else{
        [self setupCover:self.currentIndexPath.row];
    }
    
}

#pragma mark - UICllectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageAsserts.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HGAddAblumCellTableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addCell" forIndexPath:indexPath];
    cell.imageData = self.imageAsserts[indexPath.row];
    cell.indexPath= indexPath;
    cell.delegate = self;
    return cell;
}

#pragma mark - Cell delegate
-(void)didClikedCell:(HGAddAblumCellTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    self.currentIndexPath = indexPath;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片操作"
                                                             delegate:self
                                                    cancelButtonTitle:@"返回"
                                               destructiveButtonTitle:@"清除图片"
                                                    otherButtonTitles:@"设为封面", nil];
    [actionSheet showInView:self.view];
}

-(void)setupCover:(NSInteger )index{
    __weak typeof(self) mySelf = self;
    self.coverInedx = index;
    [self.imageAsserts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        HGAddAblumCellTableViewCell *cell = (HGAddAblumCellTableViewCell *)[mySelf.collectionView cellForItemAtIndexPath:indexPath];
        if (indexPath.row == index) {
            cell.cover = YES;
            
            mySelf.coverImageName = [NSString stringWithFormat:@"%03lu.jpg",(long)indexPath.row+1];
        }else{
            cell.cover = NO;
        }
    }];
}

-(void)updateButtonState{
    self.choosePicBtn.enabled = self.imageAsserts.count!=kMaxCountOfPics;
    self.takeImageBtn.enabled = self.imageAsserts.count != kMaxCountOfPics;
}

-(void)removeDataAtNSIndexPath:(NSIndexPath *)indexPath{
    HGAddAblumCellTableViewCell *cell = (HGAddAblumCellTableViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self.imageAsserts removeObject:cell.imageData];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
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
