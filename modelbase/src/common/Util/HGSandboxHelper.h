//
//  HGSandboxHelper.h
//  modelbase
//
//  Created by HamGuy on 6/6/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>


//typedef enum
//{
//    HOME=0,
//    DOCUMENT,
//    CACHE,
//    LIBRARY,
//    TMP
//}DirectoryType;

@interface HGSandboxHelper : NSObject

+(HGSandboxHelper *) sharedInstance;
+ (void)clearTmpDirectory;
+(CGFloat)getTotalDiskSpace;
+(CGFloat)getFressSpace;

-(void) createDirectory:(NSString *)directoryName;
-(void) createFile:(NSString *)fileName fileContent:(NSString *)fileContent ;
-(void) createFile:(NSString *)fileName withData:(NSData *)fileData;

-(NSString *) getAppMainDocumentDirectory;
-(NSString *) getAppCacheDirectory;
-(NSString *) getAppLibraryDirectory;
-(NSString *) getAppTmpDirectory;

-(NSArray *) getFileListsOfDirectory:(NSString *)directoryName;
-(NSArray *) getFileListsOfDirectory:(NSString *)directoryName ofFileExtention:(NSArray *)fileExtentions;
-(NSArray *)getDirectoryListOfDirectory:(NSString *)directory;


-(BOOL) isFileExist:(NSString *)fileName;
-(BOOL) isFileExist:(NSString *)directory fileName:(NSString *)fileName;
-(BOOL) isDirectoryExist:(NSString *)directoryName;
-(BOOL) isDirectoryExist:(NSString *)filePath directory:(NSString *)directoryName;

-(void) writeContent:(NSString *)fileContent toFile:(NSString *)fileName;
-(void) writeData:(NSData *)data toFile:(NSString *)fileName;


-(NSString *) getContentOfFile:(NSString *)fileName;
-(NSData *) getDataOfFile:(NSString *)fileName;

-(void) copyFileAtPath:(NSString *)from toPath:(NSString *)to;

-(void) moveFileAtPath:(NSString *)from toPath:(NSString *)to;

-(void) deleteFile:(NSString *)fileName;


@end
