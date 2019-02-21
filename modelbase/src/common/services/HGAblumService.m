//
//  HGAblumService.m
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumService.h"
#import "Cover.h"
#import "Ablum.h"

@implementation HGAblumService

-(NSOperation *)getHomePageDataSuccessed:(OperationSuccessBlock)successBlock error:( MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"fontpage"} copy];
    
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dic = result;
        NSArray *array = [dic objectForKey:@"images"];
        
        __block NSMutableArray *bannerArray = [@[] mutableCopy];
        __block NSMutableArray *newArray = [@[] mutableCopy];
        __block NSMutableArray *vipArray = [@[] mutableCopy];
        __block NSMutableArray *recArray = [@[] mutableCopy];
        __block NSMutableArray *corpArray = [@[] mutableCopy];
        
        [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            NSString *dataType =[super stringFromObject:[dict objectForKey:@"datatype"]];
            NSString *ablumId = [dict objectForKey:@"id"];
            Cover *cover = nil;
            cover = [Cover coverForAblum:ablumId withDataType:dataType];
            if ([dataType isEqualToString:@"banner"]) {
                cover = nil;
            }
            if (cover==nil) {
                cover = [Cover MR_createEntity];
            }
            cover.title = [super stringFromObject:[dict objectForKey:@"title"]];
            cover.path = [super stringFromObject:[dict objectForKey:@"path"]];
            cover.datatype = dataType;
            
            cover.ablumid = ablumId;
            
            if ([cover.datatype isEqualToString:@"banner"]) {
                [bannerArray addObject:cover];
            }else if([cover.datatype isEqualToString:@"new"]){
                [newArray addObject:cover];
            }else if([cover.datatype isEqualToString:@"vip"]){
                [vipArray addObject:cover];
            }else if([cover.datatype isEqualToString:@"cooper"]){
                [corpArray addObject:cover];
            }else if([cover.datatype isEqualToString:@"master"]){
                [recArray addObject:cover];
            }
        }];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        NSDictionary *dictresult = [@{@"banner": bannerArray,
                                      @"new":newArray,
                                      @"vip":vipArray,
                                      @"cooper":corpArray,
                                      @"master":recArray} copy];
        
        successBlock(completedOperation,dictresult);
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)getAblumListWithAblumType:(NSString *)ablumType atPage:(NSInteger)page Successed:(HGPageAbleSuccessRequestBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"booklist",
                             @"list":ablumType,
                             @"page":[NSString stringWithFormat:@"%ld",(long)page]} copy];
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSInteger totalCount =  [[dict objectForKey:@"totalcount"] integerValue];
        NSArray *array = [dict objectForKey:@"images"];
        __block NSMutableArray *resultArray= [@[] mutableCopy];
        [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            Ablum *ablum = [Ablum getAblumWithId:[dict objectForKey:@"id"]];
            if (ablum == nil) {
                ablum =[Ablum MR_createEntity];
            }
            [ablum MR_importValuesForKeysWithObject:obj];
            ablum.ablumid = [obj objectForKey:@"id"];
            ablum.abdescription = [super stringFromObject:[obj objectForKey:@"description"]];
            ablum.time = [self dateFrromString:[obj objectForKey:@"time"]];
            [resultArray addObject:ablum];
        }];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        successBlock(completedOperation,resultArray,totalCount);
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)getAblunmDetailWithId:(NSString *)ablumId Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"book",
                             @"id":ablumId} copy];
    
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        //        NSArray *array = [dict objectForKey:@"images"];
        Ablum *ablum = [Ablum getAblumWithId:[dict objectForKey:@"id"]];
        if (ablum == nil) {
            ablum =[Ablum MR_createEntity];
        }
        [ablum MR_importValuesForKeysWithObject:dict];
        ablum.ablumid = [dict objectForKey:@"id"];
        ablum.abdescription = [super stringFromObject:[dict objectForKey:@"description"]];
        ablum.time = [self dateFrromString:[dict objectForKey:@"time"]];
        ablum.goodme = [[dict objectForKey:@"goodme"] intValue];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        successBlock(completedOperation,ablum);
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)downloadAblumWithId:(NSString *)ablumId toFile:(NSString *)filePath progress:(MKNKProgressBlock)progressBlock Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"download",
                             @"id":ablumId} copy];
    
    NSOperation *operation = [super downLoadOperationWithParams:paras toFilePath:filePath progress:^(double progress) {
        progressBlock(progress);
    } successBlock:^(MKNetworkOperation *completedOperation, id result) {
        successBlock(completedOperation,result);
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)postLikeWithBookId:(NSString *)bookId isLike:(BOOL)like Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":like ? @"zan" : @"buzan",
                             @"id":bookId} copy];
    
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSString *str = [dict objectForKey:@"errormessgae"];
        if ([str isEqualToString:@"success"]) {
            successBlock(completedOperation,nil);
        }else{
            errorBlock([NSError errorWithDomain:@"Unknown Error" code:0 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)searchAblumWithSearchCondition:(NSDictionary *)condition Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSOperation *operation = [super postOperationParams:condition successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSArray *array = [dict objectForKey:@"images"];
        __block NSMutableArray *resultArray= [@[] mutableCopy];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Ablum *ablum = [Ablum getAblumWithId:[dict objectForKey:@"id"]];
            if (ablum == nil) {
                ablum =[Ablum MR_createEntity];
            }
            [ablum MR_importValuesForKeysWithObject:obj];
            ablum.ablumid = [obj objectForKey:@"id"];
            ablum.time = [super dateFrromString:[obj objectForKey:@"time"]];
            [resultArray addObject:ablum];
        }];
        successBlock(completedOperation,resultArray);
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *) createAblum:(NSDictionary *)ablumInfo Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSOperation *operation = [super  postOperationParams:ablumInfo successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if (dict && [dict objectForKey:@"errormessage"]) {
            if ([[dict objectForKey:@"errormessage"] isEqualToString:@"ok"]) {
                successBlock(completedOperation,dict);
            }else{
                errorBlock([NSError errorWithDomain:@"上传专辑失败，请稍后重试！" code:-1 userInfo:nil]);
            }
        }else{
             successBlock(completedOperation,dict);
            //errorBlock([NSError errorWithDomain:@"服务器错误，请稍后重试！" code:-1 userInfo:nil]);
        }
        
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)uploadImage:(NSDictionary *)imgInfo file:(NSString *)file progress:(MKNKProgressBlock)progressBlock Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    
    NSOperation *operation = [super uploadImage:imgInfo file:file progress:^(double progress) {
        progressBlock(progress);
    } successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if ([dict[@"errormessage"] isEqualToString:@"ok"]) {
            successBlock(completedOperation,result);
        }else{
            errorBlock([NSError errorWithDomain:@"上传图片失败" code:-2 userInfo:nil]);
        }
    } error:^(NSError *error) {
        
    }];
    return operation;
}

-(NSOperation *)deleteAblum:(NSString *)ablumId Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"delete",
                             @"id":ablumId} copy];
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSString *str = [dict objectForKey:@"result"];
        if ([str isEqualToString:@"ok"]) {
            successBlock(completedOperation,nil);
        }else{
            errorBlock([NSError errorWithDomain:@"Unknown Error" code:0 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)delePhoto:(NSString *)photoName fromAblum:(NSString *)ablumId Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *dic = @{@"image":photoName};
    NSDictionary *paras = [@{@"requesttype":@"deleteimgs",
                             @"id":ablumId,
                             @"images":@[dic]} copy];
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSString *str = [dict objectForKey:@"result"];
        if ([str isEqualToString:@"ok"]) {
            successBlock(completedOperation,nil);
        }else{
            errorBlock([NSError errorWithDomain:@"Unknown Error" code:0 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

@end
