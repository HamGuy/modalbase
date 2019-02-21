//
//  HGLocalAblumsManager.m
//  modelbase
//
//  Created by HamGuy on 6/1/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGLocalAblumsManager.h"
#import "HGSandboxHelper.h"
#import <ZipArchive/ZipArchive.h>
#import "NSString+Extentions.h"

#define kTitleDict @"allUploadTitles"

@interface HGLocalAblumsManager ()

@property (nonatomic, strong) NSMutableArray *downloadedAblums;
@property (nonatomic, strong) NSMutableDictionary *myLocalAblumTitles;

@end

@implementation HGLocalAblumsManager

SINGLETON_GCD(HGNavigationController);

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![[HGSandboxHelper sharedInstance] isDirectoryExist:KDownLoadCoverDirectoryName]) {
            [[HGSandboxHelper sharedInstance] createDirectory:KDownLoadCoverDirectoryName];
        }
        if (![[HGSandboxHelper sharedInstance] isDirectoryExist:kFileToUplaodDirectoryName]) {
            [[HGSandboxHelper sharedInstance] createDirectory:kFileToUplaodDirectoryName];
        }
    }
    return self;
}

-(void)addDownloadedAblum:(NSString *)ablumId{
    if (![self isAlreadyDownLoaded:ablumId]) {
        [self.downloadedAblums addObject:ablumId];
        [self save];
    }
}

-(BOOL)isAlreadyDownLoaded:(NSString *)ablumId{
    return [self.downloadedAblums containsObject:ablumId];
}

-(BOOL)unZipAblum:(NSString *)ablumId fromTmpFilePath:(NSString *)filePath{
    BOOL result = NO;
    NSString *filePathToWrite = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",kDownloadedDirectoyName,ablumId]];
    ZipArchive *zip = [[ZipArchive alloc] init];
    result = [zip UnzipOpenFile:filePath];
    if (result) {
        result = [zip UnzipFileTo:filePathToWrite overWrite:YES];
        [[HGSandboxHelper sharedInstance] deleteFile:filePath];
    }
    return result;
}

-(void)addCoverImage:(NSData *)coverImageData forAblum:(NSString *)ablum{
    NSString *fileName = [KDownLoadCoverDirectoryName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",ablum]];
    [[HGSandboxHelper sharedInstance] createFile:fileName withData:coverImageData];
}

-(NSArray *)allPicsOfAblum:(NSString *)ablumId{
    return [[HGSandboxHelper sharedInstance] getFileListsOfDirectory:[NSString stringWithFormat:@"%@/%@",kDownloadedDirectoyName,ablumId] ofFileExtention:@[@"jpg",@"png"]];
}

-(NSArray *)allAblums{
    return [[HGSandboxHelper sharedInstance] getDirectoryListOfDirectory:kDownloadedDirectoyName];
}


-(NSString *)coverImagePathForAblum:(NSString *)ablum{
    NSString *filePath = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.jpg",KDownLoadCoverDirectoryName,ablum]];
    return filePath;
}

-(void)deleteDownloadedAblum:(NSString *)ablumId{
    //删除图片
    [[HGSandboxHelper sharedInstance] deleteFile:[kDownloadedDirectoyName stringByAppendingPathComponent:ablumId]];
    //删除封面
    NSString *fileName = [KDownLoadCoverDirectoryName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",ablumId]];
    [[HGSandboxHelper sharedInstance] deleteFile:fileName];
    //删除记录
    [self.downloadedAblums removeObject:ablumId];
    [self save];
}

-(void)deleteUploadedABlum:(NSString *)ablumId{
    
}

#pragma mark - Upload
-(NSMutableDictionary *) allLocalTitles{
    return self.myLocalAblumTitles;
}


-(void)addCoverTitle:(NSString *)title forAblum:(NSString *)ablumId{
    [self.myLocalAblumTitles setObject:title forKey:ablumId];
    [self saveLocalTitles];
}

-(NSMutableDictionary *)myLocalAblumTitles{
    if (_myLocalAblumTitles == nil) {
        NSString *strTitlepath = [self localtitlePath];
        NSData *data = [[HGSandboxHelper sharedInstance] getDataOfFile:strTitlepath];
        if (data) {
            _myLocalAblumTitles = [[NSMutableDictionary alloc] initWithData:data];
        }else{
            _myLocalAblumTitles = [@{} mutableCopy];
        }
    }
    return _myLocalAblumTitles;
}


-(NSArray *)allLocalPicsOfAblum:(NSString *)ablumId{
        return [[HGSandboxHelper sharedInstance] getFileListsOfDirectory:[NSString stringWithFormat:@"%@/%@",kFileToUplaodDirectoryName,ablumId] ofFileExtention:@[@"jpg",@"png"]];
}

-(NSArray *)allLocThumsOfAblum:(NSString *)ablumId{
    return [[HGSandboxHelper sharedInstance] getFileListsOfDirectory:[NSString stringWithFormat:@"%@/%@",kFileToUploadThumDirectry,ablumId] ofFileExtention:@[@"jpg",@"png"]];
}


#pragma mark - Private 

-(NSMutableArray *)downloadedAblums{
    if (_downloadedAblums == nil) {
        _downloadedAblums = [[NSArray arrayWithContentsOfFile:[self filePath]] mutableCopy];
        [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[self filePath]]];
        if (_downloadedAblums == nil) {
            _downloadedAblums = [NSMutableArray array];
        }
    }
    return _downloadedAblums;
}

-(void)save{
    if ([[HGSandboxHelper sharedInstance] isFileExist:[self filePath]]) {
        [[HGSandboxHelper sharedInstance] deleteFile:[self filePath]];
    }
    [self.downloadedAblums writeToFile:[self filePath] atomically:YES];
}

-(void)saveLocalTitles{
    
    if ([[HGSandboxHelper sharedInstance] isFileExist:[self localtitlePath]]) {
        [[HGSandboxHelper sharedInstance] deleteFile:[self localtitlePath]];
    }
    [self.myLocalAblumTitles writeToFile:[self localtitlePath] atomically:YES];
}
                             
-(NSString *)filePath{
    return [[HGSandboxHelper sharedInstance].getAppMainDocumentDirectory stringByAppendingPathComponent:@"downloadedList"];
}

-(NSString *)localtitlePath{
    return [NSString stringWithFormat:@"%@/%@",kFileToUplaodDirectoryName,kTitleDict];;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url
{
    if (url == nil) {
        return NO;
    }
    if (([[NSFileManager defaultManager] fileExistsAtPath: [url path]])) {
        NSError *error = nil;
        BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            DLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }else{
            DLog(@"Success add with url = %@",url.absoluteString);
        }
        return success;
    }
    return NO;
}

@end
