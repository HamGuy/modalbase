//
//  HGUserInfoService.h
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGNetWorkEngine.h"

/**
 *  用户相关信息接口
 */
@interface HGUserInfoService : HGNetWorkEngine

/**
 *  登录
 *
 *  @param userName     用户名
 *  @param code         密码
 *  
 */
-(NSOperation *) loginOperationWithUsername:(NSString *)userName  Password:(NSString *)code Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  注册新用户
 *
 *  @param phonenum     电话号码
 *  @param userName     用户名
 *  @param code         密码
 *
 */
-(NSOperation *) registerUserWithUsername:(NSString *)userName  Code:(NSString *)code Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  申请角色
 *
 *  @param dict        用户相关信息
 *
 *
 */
-(NSOperation *) applyRoleWithInfo:(NSDictionary *)infoDict Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *获取收件箱信息列表
 */
-(NSOperation *)getMessagesSuccessed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  获取用户信息
 *
 *  @param userName     用户名
 *
 */
-(NSOperation *)getUserInfoWithName:(NSString *)userName Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  发送用户反馈信息
 *
 *  @param feedback     反馈信息内容
 *
 *
 */
-(NSOperation *)sendFeedback:(NSString *)feedback Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  修改用户信息
 *
 *  @param info         用户信息字典（头像、描述）
 *
 */
-(NSOperation *)modifyUserInfo:(NSDictionary *)info Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

-(NSOperation *)modifyAvatar:(NSDictionary *)imgInfo file:(NSString *)file progress:(MKNKProgressBlock)progressBlock Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;


/**
 *  获取用户专辑列表
 *
 *  @param userName     用户名
 *
 */
-(NSOperation *)getAblumListWithUserName:(NSString *)userName Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  获取通告列表
 */
-(NSOperation *)getAnnounceListSuccessed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  发通告
 *
 *  @param info       通告相关信息
 *
 */
-(NSOperation *)sendAnnouceMnet:(NSDictionary *)info Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  搜索用户
 *
 *  @param searchCondition 搜索条件
 *
 */
-(NSOperation *)searchUserWithCondition:(NSDictionary *)searchCondition Successed:(HGPageAbleSuccessRequestBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  获取指定用户的详细信息
 *
 *  @param userid 用户id
 *
 */
-(NSOperation *)getUserDetail:(NSString *)userid Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;
@end

