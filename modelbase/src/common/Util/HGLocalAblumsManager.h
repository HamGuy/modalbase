//
//  HGLocalAblumsManager.h
//  modelbase
//
//  Created by HamGuy on 6/1/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGLocalAblumsManager : NSObject

+(HGLocalAblumsManager *)sharedInstance;

-(void)addDownloadedAblum:(NSString *)ablumId;
-(void)addCoverImage:(NSData *)coverImageData forAblum:(NSString *)ablum;
-(BOOL)isAlreadyDownLoaded:(NSString *)ablumId;
-(BOOL)unZipAblum:(NSString *)ablumId fromTmpFilePath:(NSString *)filePath;
-(void)deleteDownloadedAblum:(NSString *)ablumId;
-(void)deleteUploadedABlum:(NSString *)ablumId;

-(NSArray *)allPicsOfAblum:(NSString *)ablumId;
-(NSArray *)allAblums;
-(NSString *)coverImagePathForAblum:(NSString *)ablumId;

-(NSMutableDictionary *)allLocalTitles;
-(NSArray *)allLocalPicsOfAblum:(NSString *)ablumId;
-(NSArray *)allLocThumsOfAblum:(NSString *)ablumId;
-(void)addCoverTitle:(NSString *)title forAblum:(NSString *)ablumId;


@end
