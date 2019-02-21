//
//  HGUploadManager.m
//  modelbase
//
//  Created by HamGuy on 7/2/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGUploadManager.h"
#import "HGCurretUserContext.h"
#import "HGSandboxHelper.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import <ASIHTTPRequest/ASINetworkQueue.h>
#import <MKNetworkKit/Categories/NSDictionary+RequestEncoding.h>
//#import 


@interface HGUploadManager ()<ASIHTTPRequestDelegate,ASIProgressDelegate>

@property (nonatomic, strong)  ASINetworkQueue *operationQueue;
@property (nonatomic, copy) UpLoadCompletedBlock uploadCompletedBlock;
@property (nonatomic, copy) UpLoadPrggressBlock upLoadProgressBlock;
@property (nonatomic, strong) NSString *tmpFileName;
@end

@implementation HGUploadManager


#pragma mark - Public
-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)addRequestWithInfo:(NSDictionary *)dict file:(NSString *)fileName tag:(NSInteger)tag{
    NSDictionary *para = [self postDict:dict];
    NSString *filePath = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString  stringWithFormat:@"%@/%@/%@",kFileToUplaodDirectoryName,dict[@"id"],fileName]];
    self.tmpFileName = fileName;
    ASIFormDataRequest *request = [self requestWithInfo:para file:filePath];
    request.tag = tag;
    [self.operationQueue addOperation:request];
}

-(void)sigleRequestWithInfo:(NSDictionary *)dict file:(NSString *)fileName withProigress:(UpLoadPrggressBlock)progressBlock completedBlock:(UpLoadCompletedBlock)completedBlock{
    NSDictionary *para = [self postDict:dict];
    self.tmpFileName = @"cover.jpg";
    ASIFormDataRequest *request = [self requestWithInfo:para file:fileName];
    [self.operationQueue addOperation:request];
    [self startploadOperationWithProigress:progressBlock completedBlock:completedBlock];
}

-(void)startploadOperationWithProigress:(UpLoadPrggressBlock)progressBlock completedBlock:(UpLoadCompletedBlock)completedBlock{
//    [self.operationQueue cancelAllOperations];
    self.uploadCompletedBlock = completedBlock;
    self.upLoadProgressBlock = progressBlock;
    [self.operationQueue go];
}

-(void)cancelAllOperations{
    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
}

#pragma mark - Getter
-(ASINetworkQueue *)operationQueue{
    if (_operationQueue == nil) {
        _operationQueue = [[ASINetworkQueue alloc] init];
        _operationQueue.delegate = self;
        _operationQueue.uploadProgressDelegate = self;
        _operationQueue.queueDidFinishSelector = @selector(operationsDidFinished:);
        _operationQueue.requestDidFailSelector = @selector(operationsDidFaild:);
        _operationQueue.showAccurateProgress = YES;
    }
    return _operationQueue;
}


#pragma mark - Private
-(NSDictionary *)postDict:(NSDictionary *)dict{
    NSMutableDictionary *dic = [dict mutableCopy];
    if (dic == nil) {
        dic = [@{} mutableCopy];
    }
    NSString *userid = [HGCurretUserContext sharedInstance].userId;
    dic[@"user"] = userid ? : @"0";
    NSString *paraValue =[NSString stringWithFormat:@"[%@]",[dic jsonEncodedKeyValueString]];
    NSDictionary *dataDic = @{@"request":@[dic]};
    paraValue =[NSString stringWithFormat:@"%@",[dataDic jsonEncodedKeyValueString]];
    return @{@"data":paraValue};
}

-(ASIFormDataRequest *)requestWithInfo:(NSDictionary *)dict file:(NSString *)fileName{
    ASIFormDataRequest  *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kBaseUrl]];
    request.delegate = self;
    request.requestMethod = @"POST";
    request.shouldStreamPostDataFromDisk = YES;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setPostValue:obj forKey:key];
    }];
    
    [request setFile:fileName withFileName:self.tmpFileName andContentType:@"image/jpeg"forKey:@"pic" ];
    return request;
}

#pragma mark - ASIHttprequest Delegate
-(void)operationsDidFinished:(ASINetworkQueue *)queue{
    if (self.operationQueue) {
        
        if (self.uploadCompletedBlock) {
            self.uploadCompletedBlock(YES,nil);
        }
        self.operationQueue = nil;
    }
}

-(void)operationsDidFaild:(ASIHTTPRequest *)request{
    [request cancel];
    if (self.uploadCompletedBlock) {
        NSError *error = [NSError errorWithDomain:[[request error] domain] code:request.tag userInfo:[request error].userInfo];
        self.uploadCompletedBlock(NO,error);
    }
    self.operationQueue = nil;
}

-(void)setProgress:(float)newProgress{
    DLog(@"called with progress: %f",newProgress);
    if (self.upLoadProgressBlock) {
        self.upLoadProgressBlock(newProgress);
    }
}

@end
