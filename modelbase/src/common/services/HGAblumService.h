//
//  HGAblumService.h
//  modelbase
//
//  Created by HamGuy on 5/26/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGNetWorkEngine.h"

/**
 *  专辑相关信息接口
 */
@interface HGAblumService : HGNetWorkEngine

/**
 *  请求首页信息
 *
 *  @param successBlock 成功处理Block
 *  @param errorBlock   失败处理Block
 *
 */
-(NSOperation *) getHomePageDataSuccessed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  请求列表信息
 *
 *  @param ablumType    专辑类型 'new' 'master' 'vip' 'cooper'
 *
 */
-(NSOperation *) getAblumListWithAblumType:(NSString *)ablumType atPage:(NSInteger)page Successed:(HGPageAbleSuccessRequestBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  请求专辑详情
 *
 *  @param ablumId      专辑id
 *
 */
-(NSOperation *) getAblunmDetailWithId:(NSString *)ablumId Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *   下载专辑
 *
 *  @param ablumId      专辑id
 *
 */
-(NSOperation *) downloadAblumWithId:(NSString *)ablumId toFile:(NSString *)filePath progress:(MKNKProgressBlock)progressBlock Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  点赞
 *
 *  @param bookid       专辑id
 *
 */
-(NSOperation *) postLikeWithBookId:(NSString *)bookId isLike:(BOOL)like Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  搜索条件
 *
 *  @param condition    动态构造的搜索条件字典
 *
 */
-(NSOperation *) searchAblumWithSearchCondition:(NSDictionary *)condition Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  创建专辑
 *
 *  @param ablumInfo    相册信息
 *  
 */
-(NSOperation *) createAblum:(NSDictionary *)ablumInfo Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  上传图片
 *
 *  @param imgInfo       图片信息：（专辑id，是否是封面，或者图片编号）
 *  @param file          文件名 *
 *  
 */
-(NSOperation *) uploadImage:(NSDictionary *)imgInfo file:(NSString *)file progress:(MKNKProgressBlock)progressBlock Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  删除专辑
 *
 *  @param ablumId      专辑id
 *
 */
-(NSOperation *) deleteAblum:(NSString *)ablumId Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;

/**
 *  从专辑中删除图片
 *
 *  @param photoName    图片名
 *  @param ablumId      专辑id
 *
 */
-(NSOperation *)delePhoto:(NSString *)photoName fromAblum:(NSString *)ablumId Successed:(OperationSuccessBlock)successBlock error:(MKNKErrorBlock)errorBlock;
@end

