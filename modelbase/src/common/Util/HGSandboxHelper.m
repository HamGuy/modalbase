//
//  HGSandboxHelper.m
//  modelbase
//
//  Created by HamGuy on 6/6/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGSandboxHelper.h"
#import "NSString+Extentions.h"
#include <sys/param.h>
#include <sys/mount.h>

@interface HGSandboxHelper ()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *documentPath;
@property (nonatomic, strong) NSError *error;

@end

@implementation HGSandboxHelper

SINGLETON_GCD(HGSandboxHelper);

-(id) init
{
    self =[super init];
    if(self)
    {
        self.fileManager=[NSFileManager defaultManager];
        self.documentPath=[self getAppMainDocumentDirectory];
        self.error =[[NSError alloc] init];
    }
    return self;
}

+(CGFloat)getFressSpace{
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
    }
    return totalFreeSpace;
}


+(CGFloat)getTotalDiskSpace{
    uint64_t totalSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
    
    NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
            totalSpace = [fileSystemSizeInBytes floatValue];
    }
    return totalSpace;
}


#pragma mark - create file
-(void) createDirectory:(NSString *)directoryName
{
    directoryName =[_documentPath stringByAppendingPathComponent:directoryName];
    [_fileManager createDirectoryAtPath:directoryName withIntermediateDirectories:YES attributes:nil error:nil];
}


-(void)createFile:(NSString *)fileName fileContent:(NSString *)fileContent
{
    [self createFile:fileName withData:[fileContent toUTF8Data]];
}

-(void)createFile:(NSString *)fileName withData:(NSData *)fileData
{
    if([fileName containsString:_documentPath]==NO)
        fileName=[_documentPath stringByAppendingPathComponent:fileName];
    [_fileManager createFileAtPath:fileName contents:fileData attributes:nil];
}


#pragma mark - query directory

-(NSString *)getAppMainDocumentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[NSString alloc] initWithString:([paths count] > 0) ? [paths objectAtIndex:0] : nil];
}

-(NSString *)getAppCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[NSString alloc] initWithString:([paths count] > 0) ? [paths objectAtIndex:0] : nil];
}

-(NSString *)getAppLibraryDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[NSString alloc] initWithString:([paths count] > 0) ? [paths objectAtIndex:0] : nil];
}

-(NSString *)getAppTmpDirectory
{
    return NSTemporaryDirectory();
}

-(NSArray *)getFileListsOfDirectory:(NSString *)directoryName
{
    directoryName = [_documentPath stringByAppendingPathComponent:directoryName];
    return [_fileManager subpathsOfDirectoryAtPath:directoryName error:nil];
}

-(NSArray *)getFileListsOfDirectory:(NSString *)directoryName ofFileExtention:(NSArray *)fileExtentions{
    NSMutableArray *filenamelist = [NSMutableArray array];
    NSString *dest = [[self getAppMainDocumentDirectory] stringByAppendingPathComponent:directoryName];
    NSArray *tmplist = [_fileManager contentsOfDirectoryAtPath:dest error:nil];
    
    for (NSString *filename in tmplist) {
        NSString *fullpath = [directoryName stringByAppendingPathComponent:filename];
        if ([self isFileExist:fullpath] && fileExtentions) {
            for (NSString *str in fileExtentions) {
                if ([[filename pathExtension] isEqualToString:str]) {
                    [filenamelist  addObject:fullpath];
                }
            }
        }
    }
    return filenamelist;
}

-(NSArray *)getDirectoryListOfDirectory:(NSString *)directory{
    NSMutableArray *filenamelist = [NSMutableArray array];
    __block NSString *dest = [[self getAppMainDocumentDirectory] stringByAppendingPathComponent:directory];
    NSArray *tmplist = [_fileManager contentsOfDirectoryAtPath:dest error:nil];
    
    [tmplist enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
        NSString *fullpath = [dest stringByAppendingPathComponent:fileName];
        BOOL isDir = YES;
        if ([_fileManager fileExistsAtPath:fullpath isDirectory:&isDir])
        {
                [filenamelist addObject:fileName];
        }
    }];
    return filenamelist;
}

#pragma mark - CheckFile

-(BOOL)isFileExist:(NSString *)fileName
{
    if([fileName containsString:_documentPath]==NO)
        fileName=[_documentPath stringByAppendingPathComponent:fileName];
    return [_fileManager fileExistsAtPath:fileName];
}

-(BOOL)isFileExist:(NSString *)directory fileName:(NSString *)fileName
{
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    return [self isFileExist:filePath];
}

-(BOOL)isDirectoryExist:(NSString *)directoryName{
    BOOL isDir =YES;
    return [self.fileManager fileExistsAtPath:directoryName isDirectory:&isDir];
}

-(BOOL)isDirectoryExist:(NSString *)filePath directory:(NSString *)directoryName
{
    if([filePath containsString:_documentPath]==NO)
        filePath=[_documentPath stringByAppendingPathComponent:filePath];
    
    filePath=[filePath stringByAppendingPathComponent:directoryName];
    BOOL isDir =YES;
    return [_fileManager fileExistsAtPath:filePath isDirectory:&isDir];
}

#pragma mark - file operation
-(void)writeContent:(NSString *)fileContent toFile:(NSString *)fileName
{
    NSMutableData *fileData =[[NSMutableData alloc] init];
    [fileData appendData:[fileContent toUTF8Data]];
    if([self isFileExist:fileName]==NO)
    {
        [self createFile:fileName withData:fileData];
    }
    else
    {
        [fileData writeToFile:fileName atomically:YES];
    }
}

-(void)writeData:(NSData *)data toFile:(NSString *)fileName
{
    if ([self isFileExist:fileName]==NO) {
        [self createFile:fileName withData:data];
    }
    else
        [data writeToFile:fileName atomically:YES];
}


-(NSString *)getContentOfFile:(NSString *)fileName
{
    NSData *data = [self getDataOfFile:fileName];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


-(NSData *)getDataOfFile:(NSString *)fileName
{
    fileName =[_documentPath stringByAppendingPathComponent:fileName];
    return [NSData dataWithContentsOfFile:fileName];
}

-(void)moveFileAtPath:(NSString *)from toPath:(NSString *)to
{
    from=[_documentPath stringByAppendingPathComponent:from];
    to=[_documentPath stringByAppendingPathComponent:to];
    [_fileManager moveItemAtPath:from toPath:to error:nil];
}

-(void)copyFileAtPath:(NSString *)from toPath:(NSString *)to
{
    if (from==nil) {
        return;
    }
    
    //    from=[documentPath stringByAppendingPathComponent:from];
    NSError *myerror=[[NSError alloc] init];
    to=[_documentPath stringByAppendingPathComponent:to];
    
    if([_fileManager copyItemAtPath:from toPath:to error:&myerror]==NO)
        NSLog(@"Error = %@",[myerror description]);
}

#pragma mark - delete operation
-(void)deleteFile:(NSString *)fileName
{
    if([fileName containsString:_documentPath]==NO)
        fileName = [_documentPath stringByAppendingPathComponent:fileName]
        ;
    
    if([self isFileExist:fileName]==NO)
        return;
    
    if([_fileManager isDeletableFileAtPath:fileName])
        [_fileManager removeItemAtPath:fileName error:nil];
}

+ (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}
@end

