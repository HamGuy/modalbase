//
//  HGNetWorkEngine.m
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGNetWorkEngine.h"
#import "url.pch"
#import "HGSandboxHelper.h"
#import "HGCurretUserContext.h"

@interface HGNetWorkEngine ()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation HGNetWorkEngine

-(MKNetworkOperation *)postOperationParams:(NSDictionary *)paras successBlock:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    return [self hgPostOperationWithUrl:kBaseUrl params:paras httpMethod:@"POST" successBlock:successBlock error:errorBlock];
}

-(MKNetworkOperation *)downLoadOperationWithParams:(NSDictionary *)paras toFilePath:(NSString *)filePath progress:(MKNKProgressBlock)progressBlock successBlock:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    MKNetworkOperation *operation = [self operationWithURLString:kBaseUrl params:paras httpMethod:@"POST"];
    
    
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation addDownloadStream:stream];
    
    [operation onDownloadProgressChanged:^(double progress) {
        DLog(@"progress is %f",progress);
        progressBlock(progress);
    }];
    
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        successBlock(completedOperation,filePath);
    }errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:operation];
    return operation;
}

-(MKNetworkOperation *)uploadImage:(NSDictionary *)dict file:(NSString *)file progress:(MKNKProgressBlock)progressBlock successBlock:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    
    BOOL isAvatar = dict.count == 1;
    
    NSMutableDictionary *dic = [dict mutableCopy];
    if (dic == nil) {
        dic = [@{} mutableCopy];
    }
    NSString *userid = [HGCurretUserContext sharedInstance].userId;
    dic[@"user"] = userid ? : @"0";
    NSString *paraValue =[NSString stringWithFormat:@"[%@]",[dic jsonEncodedKeyValueString]];
    NSDictionary *dataDic = @{@"request":@[dic]};
    paraValue =[NSString stringWithFormat:@"%@",[dataDic jsonEncodedKeyValueString]];
    dict = @{@"data":paraValue};
    MKNetworkOperation *operation = [super operationWithURLString:kBaseUrl params:dict httpMethod:@"POST"];
    
    NSString *fileUrl = nil;
    if (isAvatar || [[dic objectForKey:@"image"] isEqualToString:@"cover"]) {
        fileUrl = file;
    }else{
        fileUrl = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",kFileToUplaodDirectoryName,dic[@"id"],file]];
    }
//    [operation set]
//    [operation setUploadStream:[NSInputStream inputStreamWithFileAtPath:fileUrl]];
    [operation addFile:@"" forKey:@"pic"];
    [operation onUploadProgressChanged:^(double progress) {
        DLog(@"upload progress is %f",progress);
        progressBlock(progress);
    }];
    
    __weak typeof(self) mySelf = self;
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *json = [completedOperation responseJSON];
        if (json==nil) {
            errorBlock([NSError errorWithDomain:@"服务器错误，请稍后重试！" code:-1 userInfo:nil]);
        }else{
            successBlock(completedOperation,json);
        }
        
        [mySelf.workingOperations removeObject:completedOperation];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    
    [self enqueueOperation:operation];
    return operation;
}



/**
 *  取消所有队列请求
 */
- (void)cancelAllOperations {
    [self.workingOperations makeObjectsPerformSelector:@selector(cancel)];
    [self.workingOperations removeAllObjects];
}


#pragma mark - Private
-(MKNetworkOperation *)hgPostOperationWithUrl:(NSString *)url params:(NSDictionary *)params httpMethod:(NSString *)httpMethod successBlock:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    
    MKNetworkOperation *operation = [self operationWithURLString:url params:params httpMethod:httpMethod];
    
    __weak typeof(self) mySelf = self;
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *json = [completedOperation responseJSON];
        if (json==nil) {
            errorBlock([NSError errorWithDomain:@"服务器错误，请稍后重试！" code:-1 userInfo:nil]);
        }else{
            successBlock(completedOperation,json);
        }
        
        [mySelf.workingOperations removeObject:completedOperation];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if ([error.domain isEqualToString:@"NSURLErrorDomain"]) {
            error = [NSError errorWithDomain:@"网络错误，请检查网络配置" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"网络错误，请检查网络配置。"}];
        }
        errorBlock(error);
        [mySelf.workingOperations removeObject:completedOperation];
    }];
    
    [self enqueueOperation:operation];
    return operation;
}

- (void)cancelOperation:(NSOperation *)operation {
    [operation cancel];
    [self.workingOperations removeObject:operation];
}

#pragma mark - Override

//构造函数
- (id) initWithHostName:(NSString*) hostName customHeaderFields:(NSDictionary*) headers{
    self = [super initWithHostName:hostName customHeaderFields:headers];
    if (self) {
        self.workingOperations = [NSMutableArray array];
        return self;
    }
    return nil;
}


-(void)enqueueOperation:(MKNetworkOperation *)operation forceReload:(BOOL)forceReload{
    [super enqueueOperation:operation forceReload:forceReload];
    
    if (![self.workingOperations containsObject:operation]) {
        [self.workingOperations addObject:operation];
    }
}

-(int)cacheMemoryCost {
    return 1;
}

-(void)dealloc{
    [self cancelAllOperations];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 *  主要是为了添加公共字段，userid, 实现特有的通讯协议
 *
 *  @param urlString url
 *  @param body      params dict
 *  @param method    httpMethod
 *
 *  @return the net operation
 */
-(MKNetworkOperation *) operationWithURLString:(NSString *)urlString params:(NSDictionary *)body httpMethod:(NSString *)method{
    NSMutableDictionary *dic = [body mutableCopy];
    if (dic == nil) {
        dic = [@{} mutableCopy];
    }
    NSString *userid = [HGCurretUserContext sharedInstance].userId;
    dic[@"user"] = userid ? : @"0";
    
    NSString *paraValue =[NSString stringWithFormat:@"[%@]",[dic jsonEncodedKeyValueString]];
    //请求数据包格式为 request=[{"requesge","user":"0"}]'的格式
    NSDictionary *dataDic = @{@"request":paraValue};
    
    return [super operationWithURLString:urlString params:dataDic httpMethod:method];
}

-(NSDate *)dateFrromString:(NSString *)strDate{
    NSDate *date =nil;
    date = [self.formatter dateFromString:strDate];
    return date;
}

-(NSDateFormatter *)formatter{
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//2014-05-12 09:42:53
    }
    return _formatter;
}

-(NSString *)stringFromObject:(id)obj{
    NSString *str = @"";
    if ([obj isKindOfClass:[NSString class]]) {
        str  = (NSString *)obj;
        if (str.length==0) {
            return @"";
        }
    }
    else if([obj isKindOfClass:[NSNumber class]]){
        
    }
    return str;
}
@end

