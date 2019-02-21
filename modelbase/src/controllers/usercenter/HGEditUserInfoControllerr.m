//
//  HGEditUserInfoControllerr.m
//  modelbase
//
//  Created by HamGuy on 6/1/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGEditUserInfoControllerr.h"
#import "GCPlaceholderTextView.h"
#import "HGCurretUserContext.h"
#import "HGRegisterStepTwoController.h"
#import "QBImagePickerController.h"
#import "UIImageView+Rounded.h"
#import "HGPopContainerView.h"
#import "UIImage+Resize.h"
#import "HGUserInfoService.h"
#import "UserInfo.h"
#import "UIImageView+Loading.h"
#import "HGSandboxHelper.h"
#import "HGUploadManager.h"
#import "VPImageCropperViewController.h"

#define kAvatarSize CGSizeMake(130,130)

@interface HGEditUserInfoControllerr ()<QBImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,VPImageCropperDelegate>

@property (nonatomic, weak) IBOutlet GCPlaceholderTextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *avataView;
@property (nonatomic, weak) IBOutlet UIView *editContainerView;
@property (nonatomic, strong) IBOutlet UIView *choosePicContainerView;
@property (nonatomic, strong) UIImage *tmpImage;
@property (nonatomic, strong) ALAsset *imgAsert;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) HGUserInfoService *userinfoService;
@property (nonatomic, strong) UIImage *takedImage;
@property (nonatomic, weak) IBOutlet UIButton *okBtn;
@property (nonatomic, weak) IBOutlet UIButton *applyModelBtn;
@property (nonatomic, weak) IBOutlet UIButton *applyVipBtn;
@property (nonatomic, weak) IBOutlet UIButton *applyEditorBtn;
@property (nonatomic, strong) NSString *oldInfo;
@property (nonatomic, strong) HGUploadManager *uploadManager;
@property (nonatomic, strong) VPImageCropperViewController* imageCropper;


@end

@implementation HGEditUserInfoControllerr

- (id)init
{
    self = [super initWithNibName:@"HGEditUserInfoControllerr" bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"个人信息编辑";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self isMember]) {
        self.applyEditorBtn.hidden = YES;
        self.applyModelBtn.hidden = YES;
        self.applyVipBtn.hidden = YES;
    }
    self.descriptionTextView.delegate = self;
    self.okBtn.enabled = false;
    UserInfo *info = [UserInfo userInfoWithUserNmae:[HGCurretUserContext sharedInstance].username];
    if (info.userdescrption.length ==0) {
        self.oldInfo = @"";
        self.descriptionTextView.placeholder = @"请填写职业和个人介绍";
    }else{
        self.oldInfo = info.description;
        self.descriptionTextView.text = info.userdescrption;
    }
    self.avataView.layer.cornerRadius = self.avataView.width/2.0;
    self.avataView.clipsToBounds = YES;
    if (info.head) {    __weak typeof(self) mySelf = self;
        if (info.head) {
            __block UIImage *img = nil;
            __block NSString *strUrl = info.head;
            self.avataView.image = [UIImage imageNamed:@"IconDefaultAvataSmall"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    mySelf.avataView.image = img ? : [UIImage imageNamed:@"IconDefaultAvataSmall"];
                });
            });
        }

//        [self.avataView setImageWithURL:[NSURL URLWithString:info.head] placeholderImage:[UIImage imageNamed:@"IconDefaultAvataSmall"]];
    }
    
    self.descriptionTextView.layer.cornerRadius = 5.f;
    [self.avataView roundedWithBorderWidth:2.f borderColor:[UIColor whiteColor]];
    
    self.editContainerView.layer.borderWidth = 0.5f;
    self.editContainerView.layer.borderColor = [RGBCOLOR(209, 209, 209) CGColor];
    
    [self addbackButtonWithAction:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    if (!is_iPhone5) {
        self.scrollView.contentSize = CGSizeMake(320, self.applyVipBtn.bottom+40.f);
    }else{
        self.scrollView.scrollEnabled = NO;
    }
    
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

-(HGUserInfoService *)userinfoService{
    if (_userinfoService == nil) {
        _userinfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return _userinfoService;
}

-(HGUploadManager *)uploadManager{
    if (_uploadManager == nil) {
        _uploadManager = [[HGUploadManager alloc] init];
    }
    return _uploadManager;
}

-(VPImageCropperViewController *)imageCropper{
    if (_imageCropper == nil) {
        _imageCropper = [[VPImageCropperViewController alloc] initWithImage:self.avataView.image cropFrame:CGRectMake(0, 0, 130, 130) limitScaleRatio:1.0];
        _imageCropper.delegate = self;
    }
    return _imageCropper;
}

-(void)dealloc{
    [self.userinfoService cancelAllOperations];
    self.userinfoService = nil;
    [self.uploadManager cancelAllOperations];
    self.uploadManager = nil;
}

#pragma mark - Private
-(BOOL)isMember{
    NSString *type =[HGCurretUserContext sharedInstance].type;
    return ![type isEqualToString:@"user"];
}

#pragma mark - Actions
- (void)hideKeyboard
{
    [self setEditing:NO];
    [self.descriptionTextView resignFirstResponder];
}

-(IBAction)confirmEdit:(id)sender{
    [self hideKeyboard];
    if (self.takedImage) {
        NSMutableDictionary *dict = [@{}mutableCopy];
        dict[@"requesttype"]=@"personalimage";
        __weak typeof(self) mySelf = self;
        NSData *data = UIImageJPEGRepresentation(self.takedImage, 0.75f);
        
        NSString *file = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:@"avatar.jpg"];
        [[HGSandboxHelper sharedInstance] writeData:data toFile:file];
        
        
        [self.uploadManager sigleRequestWithInfo:dict file:file withProigress:^(CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [mySelf loadingWithMsg:@"正在上传头像，请不要离开本页面" progress:progress];
            });
        } completedBlock:^(BOOL success, NSError *error) {
            if (error == nil) {
                if ([mySelf.oldInfo isEqualToString:mySelf.descriptionTextView.text]) {
                    [mySelf successedWitnMessage:@"修改头像成功！"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil userInfo:nil];
                    [mySelf.navigationController popViewControllerAnimated:YES];
                    return ;
                }
                [mySelf modifyDescription];
            }else{
                [mySelf failedWithMessage:@"上传头像失败，请稍后重试！" conmpleted:nil];
                [mySelf.uploadManager cancelAllOperations];
            }
        }];
        
//        [self.userinfoService modifyAvatar:dict file:file progress:^(double progress) {
//            [mySelf loadingWithMsg:@"" progress:progress];
//        } Successed:^(MKNetworkOperation *completedOperation, id result) {
//            if ([mySelf.oldInfo isEqualToString:mySelf.descriptionTextView.text]) {
//                [mySelf successedWitnMessage:@"修改头像成功！"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil userInfo:nil];
//                return ;
//            }
//            [mySelf modifyDescription];
//        } error:^(NSError *error) {
//            [mySelf failedWithMessage:@"上传头像失败，请稍后重试！" conmpleted:nil];
//            [mySelf modifyDescription];
//        }];
        
    }else{
        [self modifyDescription];
    }
    
}

-(void)modifyDescription{
    [self loading];
    NSMutableDictionary *dict = [@{} mutableCopy];
    dict[@"requesttype"]=@"userinfo";
    dict[@"info"]=self.descriptionTextView.text.length >0 ? self.descriptionTextView.text : @"";
    __weak typeof(self) mySelf = self;
    [self.userinfoService modifyUserInfo:dict Successed:^(MKNetworkOperation *completedOperation, id result) {
        [mySelf successedWitnMessage:@"编辑个人信息成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil userInfo:@{@"des": mySelf.descriptionTextView.text}];
        [mySelf.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        //        imageData = nil;
        [mySelf failedWithMessage:@"编辑个人信息失败" conmpleted:nil];
    }];
}

-(IBAction)applyModel:(id)sender{
    HGRegisterStepTwoController *controller = [[HGRegisterStepTwoController alloc] initWithRegisterType:RegisterTypeModel];
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)applyAgent:(id)sender{
    HGRegisterStepTwoController *controller = [[HGRegisterStepTwoController alloc] initWithRegisterType:RegisterTypeEditor];
    [self.navigationController pushViewController:controller animated:YES];
    
}

-(IBAction)applyVIP:(id)sender{
    HGRegisterStepTwoController *controller = [[HGRegisterStepTwoController alloc] initWithRegisterType:RegisterTypeVIP];
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)shouldChangeAvata:(id)sender{
    [self hideKeyboard];
    self.tmpImage = self.avataView.image;
    [HGPopContainerView showInparetView:[self rootVC].view WithView:self.choosePicContainerView animtionDuration:0.5f TapToDismiss:NO];
}

-(IBAction)chooseFromLibrary:(id)sender{
//    if ([QBImagePickerController isAccessible]) {
//        QBImagePickerController *controller = [[QBImagePickerController alloc] init];
//        controller.delegate = self;
//        HGNavigationController *nav = [[HGNavigationController alloc] initWithRootViewController:controller];
//        [self presentViewController:nav animated:YES completion:nil];
//    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = YES;
        [self presentViewController:controller animated:YES completion:nil];
        controller=nil;

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

-(IBAction)editDone:(id)sender{
    [HGPopContainerView dismiss];
}

-(IBAction)editCanceled:(id)sender{
    self.avataView.image = self.tmpImage;
    [HGPopContainerView dismiss];
}

#pragma mark - UIImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImage *originalImage= [info objectForKey:@"UIImagePickerControllerEditedImage"];
            originalImage = [originalImage resizedImage:CGSizeMake(160, 160) interpolationQuality:kCGInterpolationDefault];
            self.imgAsert = nil;
            self.takedImage = originalImage;
            self.avataView.image  = originalImage;
            originalImage = nil;
        
//    }else{
//        
//    }
    self.okBtn.enabled = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QBImagePickerControllerDelegate
-(void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset{
    
    [imagePickerController loading];
    __block CGImageRef imgRef = [asset aspectRatioThumbnail];
    __block UIImage *img = [UIImage imageWithCGImage:imgRef];
    self.takedImage = img;
    self.imgAsert = asset;
    self.avataView.image = img;
    self.okBtn.enabled = YES;
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
//        CFRelease(imgRef);
    }];
}

- (void)imagePickerControllerDidCanceled:(QBImagePickerController *)imagePickerController{
    self.avataView.image = self.tmpImage;
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

-(UIViewController *)rootVC{
    UIViewController *rootviewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(rootviewController.presentedViewController!=nil)
        rootviewController = rootviewController.presentedViewController;
    return rootviewController;
}

#pragma mark - Textview delegate
-(void)textViewDidChange:(UITextView *)textView{
    self.okBtn.enabled = ![textView.text isEqualToString:self.oldInfo] ;
}



#pragma mark - ImageCroper Delegate
-(void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage{
    [cropperViewController loading];
    self.takedImage = editedImage;
//    self.imgAsert = asset;
    self.avataView.image = editedImage;
    self.okBtn.enabled = YES;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        //        CFRelease(imgRef);
    }];
}

-(void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController{
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
