//
//  HGUserInfoService.m
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGUserInfoService.h"
#import "UserInfo.h"
#import "Cover.h"
#import "Ablum.h"
#import "HGMessage.h"
#import "HGCurretUserContext.h"
#import "AnnounceMent.h"
#import "UserBrief.h"


@implementation HGUserInfoService

-(NSOperation *)loginOperationWithUsername:(NSString *)userName Password:(NSString *)code Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"login",
                             @"name":userName,
                             @"password":code} copy]; //id is username
    
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSString *strResult =[dict objectForKey:@"errormessage"];
        if ([strResult isEqualToString:@"ok"]) {
            successBlock(completedOperation,dict);
        }else{
            errorBlock([NSError errorWithDomain:@"Faild" code:[dict[@"errorCode"] integerValue] userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
    
}

-(NSOperation *)registerUserWithUsername:(NSString *)userName Code:(NSString *)code Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"register",
                             @"name":userName,
                             @"password":code} copy]; //id is username
    
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSString *strResult =[dict objectForKey:@"errormessage"];
        if ([strResult isEqualToString:@"ok"]) {
            successBlock(completedOperation,dict);
        }else{
            errorBlock([NSError errorWithDomain:@"Faild" code:-1 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)applyRoleWithInfo:(NSDictionary *)infoDict Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSMutableDictionary *paras = [[NSMutableDictionary alloc] initWithDictionary:infoDict];
    paras[@"requesttype"] = @"upgrade";
    
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if ([[dict objectForKey:@"errormessage"] isEqualToString:@"ok"]) {
            successBlock(completedOperation,dict);
        }else{
            errorBlock([NSError errorWithDomain:@"申请角色失败" code:-2 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
    return nil;
}

-(NSOperation *)getMessagesSuccessed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"message"} copy]; //id is username
    
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSArray *messages = [dict objectForKey:@"messages"];
        __block NSMutableArray *allMessages = [@[] mutableCopy];
        if (messages.count>0) {
            [HGMessage MR_truncateAll];
            [messages enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
               
                HGMessage *msg = [HGMessage MR_createEntity];
                msg.title = [super stringFromObject:[dic objectForKey:@"title"]];
                msg.content = [super stringFromObject:[dic objectForKey:@"description"]];
                msg.sender = [super stringFromObject:[dic objectForKey:@"sender"]];
                NSString *time = [dic objectForKey:@"time"];
                msg.time = [time substringToIndex:10];
                [allMessages addObject:msg];
            }];
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            successBlock(completedOperation,allMessages);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}


-(NSOperation *)getUserInfoWithName:(NSString *)userName Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = [@{@"requesttype":@"visit",
                             @"name":userName} copy]; //id is username
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        UserInfo *info = [UserInfo userInfoWithUserNmae:userName];
        if (info==nil) {
            info = [UserInfo MR_createEntity];
        }
        if ([[dict objectForKey:@"role"] isKindOfClass:[NSString class]]) {
            info.role = [dict objectForKey:@"role"];
        }
        if ([[dict objectForKey:@"description"] isKindOfClass:[NSString class]]) {
            info.userdescrption = [dict objectForKey:@"description"];
        }
        info.error = [NSString stringWithFormat:@"%d",(int)[dict objectForKey:@"error"]];
        
        NSArray *imgArray = [dict objectForKey:@"images"];
        NSMutableOrderedSet *allCovers = [info mutableOrderedSetValueForKeyPath:@"images"];
        [allCovers removeAllObjects];
        
        for (NSDictionary *dic in imgArray) {
            Cover *cover =[Cover coverForAblum:[dic objectForKey:@"id"]];
            if (cover == nil) {
                cover = [Cover MR_createEntity];
            }
            cover.title = [super stringFromObject:[dic objectForKey:@"title"]];
            cover.ablumid = [dic objectForKey:@"id"];
            cover.path = [super stringFromObject:[dic objectForKey:@"path"]];
            cover.datatype =[super stringFromObject:[dic objectForKey:@"datatype"]];
            
            [allCovers addObject:cover];
        }
        info.username = [super stringFromObject:[dict objectForKey:@"name"]];
        info.head = [NSString stringWithFormat:@"%@%@",kBaseImageUrl,[super stringFromObject:[dict objectForKey:@"head"]]];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        successBlock(completedOperation,info);
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)sendFeedback:(NSString *)feedback Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSString *name = [HGCurretUserContext sharedInstance].username;
    NSDictionary *paras = [@{@"requesttype":@"advice",
                             @"content":feedback,
                             @"name":name ? : @"1"} copy]; //id is username
    
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if ([[dict objectForKey:@"errormessage"] isEqualToString:@"ok"]) {
            successBlock(completedOperation,dict);
        }else{
            errorBlock([NSError errorWithDomain:@"发送反馈信息失败！" code:-2 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)modifyUserInfo:(NSDictionary *)info Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSOperation *operation = [super postOperationParams:info successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if ([[dict objectForKey:@"errormessage"] isEqualToString:@"ok"]) {
            successBlock(completedOperation,dict);
        }else{
            errorBlock([NSError errorWithDomain:@"编辑个人信息失败！" code:-2 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)modifyAvatar:(NSDictionary *)imgInfo file:(NSString *)file progress:(MKNKProgressBlock)progressBlock Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    
    NSOperation *operation = [super uploadImage:imgInfo file:file progress:^(double progress) {
        progressBlock(progress);
    } successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if ([dict[@"errormessage"] isEqualToString:@"ok"]) {
            successBlock(completedOperation,result);
        }else{
            errorBlock([NSError errorWithDomain:@"修改头像失败，请稍后重试！" code:-2 userInfo:nil]);
        }
    } error:^(NSError *error) {
        
    }];
    return operation;
}


-(NSOperation *) getAblumListWithUserName:(NSString *)userName Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
//    userName = @"1";
    NSDictionary *paras = [@{@"requesttype":@"mylist",
                             @"username":userName} copy];
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if (![dict[@"errormessage"] isEqualToString:@"ok"]) {
            NSInteger errcode =(NSInteger)[dict objectForKey:@"errorcode"];
            if ([[dict allKeys] containsObject:@"errormessage"]) {
                errorBlock([NSError errorWithDomain:[dict objectForKey:@"errormessage"] code:errcode userInfo:nil]);
            }
        }else{
        NSArray *array = [dict objectForKey:@"images"];
        __block NSMutableArray *resultArray= [@[] mutableCopy];
        [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            Ablum *ablum = [Ablum getAblumWithId:[dict objectForKey:@"id"]];
            if (ablum == nil) {
                ablum =[Ablum MR_createEntity];
            }
            [ablum MR_importValuesForKeysWithObject:obj];
            ablum.ablumid = [obj objectForKey:@"id"];
            ablum.time = [super dateFrromString:[obj objectForKey:@"time"]];
            ablum.datatype = @"mylist";
            ablum.abdescription = [obj objectForKey:@"description"];
            [resultArray addObject:ablum];
        }];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        successBlock(completedOperation,resultArray);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)getAnnounceListSuccessed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSDictionary *paras = @{@"requesttype":@"tonggaolist"};
    NSOperation *operation = [super postOperationParams:paras successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if ([dict[@"errormessage"] isEqualToString:@"ok"]) {
            NSArray *array = dict[@"messages"];
            __block NSMutableArray *resultArray = [@[] mutableCopy];
            [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
                AnnounceMent *announceMnet = [[AnnounceMent alloc] init];
                [announceMnet setValuesForKeysWithDictionary:dic];
                announceMnet.content = [super stringFromObject:[dic objectForKey:@"description"]];
                [resultArray addObject:announceMnet];
            }];
            successBlock(completedOperation,resultArray);
        }else{
            errorBlock([NSError errorWithDomain:@"获取通告列表失败，请稍后重试！" code:4444 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)sendAnnouceMnet:(NSDictionary *)info Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSOperation *operation = [super postOperationParams:info successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if ([dict[@"errormessage"] isEqualToString:@"ok"]) {
            successBlock(completedOperation,nil);
        }else{
            errorBlock([NSError errorWithDomain:@"请求失败！" code:4444 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)searchUserWithCondition:(NSDictionary *)searchCondition Successed:(HGPageAbleSuccessRequestBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    NSOperation *operation = [super postOperationParams:searchCondition successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        NSInteger totalCount =  [[dict objectForKey:@"totoalcount"] integerValue];
        if ([result[@"errormessage"] isEqualToString:@"ok"]) {
            NSArray *array = dict[@"users"];
            __block NSMutableArray *resultArray = [@[] mutableCopy];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UserBrief *user = [[UserBrief alloc] init];
                [user setValuesForKeysWithDictionary:obj];
                [resultArray addObject:user];
            }];
            successBlock(completedOperation,resultArray,totalCount);
        }else{
            errorBlock([NSError errorWithDomain:@"未找到相关搜索结果！" code:4444 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

-(NSOperation *)getUserDetail:(NSString *)userid Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock{
    
    NSDictionary *info = @{@"requesttype": @"userdetail",
                           @"targetuser":userid};
    
    NSOperation *operation = [super postOperationParams:info successBlock:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary *dict = result;
        if ([result[@"errormessage"] isEqualToString:@"ok"]) {            successBlock(completedOperation,result[@"roleinfo"]);
        }else{
            errorBlock([NSError errorWithDomain:@"未找到相关搜索结果！" code:4444 userInfo:nil]);
        }
    } error:^(NSError *error) {
        errorBlock(error);
    }];
    return operation;
}

@end
