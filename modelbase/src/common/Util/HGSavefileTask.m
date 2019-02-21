//
//  HGSavefileTask.m
//  modelbase
//
//  Created by HamGuy on 7/8/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGSavefileTask.h"
#import "HGLocalAblumsManager.h"
#import "HGSandboxHelper.h"

@interface HGSavefileTask()

@property (nonatomic, strong) ALAsset *currentAsset;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, getter = isFinished)  BOOL finished;
@property (nonatomic, getter = isExecuting) BOOL executing;

@property (nonatomic, strong) HGSandboxHelper *sandBoxHelper;
@property (nonatomic, copy) OPCompletedBlock completedBlock;

@end


@implementation HGSavefileTask
@synthesize finished = _finished;
@synthesize executing = _executing;

-(id)initWithAlasset:(ALAsset *)alasset userInfo:(NSDictionary *)userInfo complted:(OPCompletedBlock)completedBlock{
    self = [super init];
    if (self) {
        self.currentAsset = alasset;
        self.userInfo = userInfo;
        _finished = NO;
        _executing = NO;
        self.completedBlock = [completedBlock copy];
        self.sandBoxHelper = [HGSandboxHelper sharedInstance];
    }
    return self;
}

- (void)start
{
    if ([self isCancelled])
    {
        self.finished = YES;
        return;
    }
    
    self.executing = YES;
    
    [self main];
}

- (void)completeOperation
{
    self.executing = NO;
    self.finished  = YES;
}

-(void)main{
    @autoreleasepool {
        NSString *ablumId = self.userInfo[@"ablumid"];
        NSInteger index = [self.userInfo[@"index"] integerValue];
        
        DLog(@"img %lu",(unsigned long)index);
        NSString *imgFileName = [NSString stringWithFormat:@"%03lu.jpg",(unsigned long)index];
        NSString *acturlFileName = [[self.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUplaodDirectoryName,ablumId,imgFileName]];
        NSString *acturlThumFileName = [[self.sandBoxHelper getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUploadThumDirectry,ablumId,imgFileName]];
        
        ALAssetRepresentation *rep = [self.currentAsset defaultRepresentation];
    
    //挂在这了，某个对象被释放？？？
        CGImageRef imgRef = [rep fullResolutionImage];
        
        //保存缩略图
        CGImageRef thumImageRef = [self resizeCGImage:imgRef toWidth:240 andHeight:180];
        CGImageRelease(imgRef); //先释放掉
        UIImage *thumImage = [UIImage imageWithCGImage:thumImageRef];
        CGImageRelease(thumImageRef); //释放内存
        NSData *thumImageData = UIImageJPEGRepresentation(thumImage, 0.8);
        [self.sandBoxHelper createFile:acturlThumFileName withData:thumImageData];
        thumImageData = nil; //释放内存
        
        imgRef = [rep fullResolutionImage]; //用的时候再生成
        rep = nil;
        UIImage *fullImage = [UIImage imageWithCGImage:imgRef];
        CGImageRelease(imgRef);//马上释放
        UIImage *maskImage = [UIImage imageNamed:@"BgWatermark"];
        //添加水印
        UIImage *maskedImage = [self image:fullImage withWaterMask:maskImage];
        maskImage = nil;
        fullImage = nil;
        
        NSData *fullImageData = UIImageJPEGRepresentation(maskedImage, 0.8);
        maskedImage = nil;
        [self.sandBoxHelper createFile:acturlFileName withData:fullImageData];
        fullImageData = nil;
        
        DLog(@"upload fileName %@",imgFileName);
        if (self.completedBlock) {
            self.completedBlock(imgFileName);
        }
    }
    //结束
    [self completeOperation];

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
    CGImageRelease(maskRef);
    mask = nil;
    UIImage *newMaskImage = [UIImage imageWithCGImage:resizeMask];
    CGImageRelease(resizeMask);
    
    CGRect rect = CGRectMake(originalImage.size.width - maskWidth, originalImage.size.height-maskHeight, maskWidth, maskHeight);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions([originalImage size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    
    //
    [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    //
    [newMaskImage drawInRect:rect];
    originalImage = nil;
    newMaskImage = nil;
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}

@end
