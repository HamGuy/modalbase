//
//  HGAsyncConnection.m
//  modelbase
//
//  Created by HamGuy on 5/20/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAsyncConnection.h"

@interface HGAsyncConnection ()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, copy) HGCompletedBlock completedBlock;
@property (nonatomic, copy) HGErrorBlock errorBlock;
@property (nonatomic, copy) HGProgressBlock progressBlock;

@property (nonatomic, assign) CGFloat totalLength;



@end

@implementation HGAsyncConnection

+ (id)request:(NSString *)requestUrl InProgress:(HGProgressBlock)progressBlock OnCompleted:(HGCompletedBlock)completedBlock withError:(HGErrorBlock)errorBlock;
{
    return [[self alloc] initWithRequest:requestUrl InProgress:progressBlock OnCompleted:completedBlock withError:errorBlock];
}

- (id)initWithRequest:(NSString *)requestUrl InProgress:(HGProgressBlock)progressBlock OnCompleted:(HGCompletedBlock)completedBlock withError:(HGErrorBlock)errorBlock
{
    NSURL *url = [NSURL URLWithString:requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.f];
    
    if (self = [super initWithRequest:request delegate:self startImmediately:NO]) {
        self.data = [[NSMutableData alloc] init];
        
        self.completedBlock = completedBlock;
        self.errorBlock = errorBlock;
        self.progressBlock = progressBlock;
        [self start];
    }
    
    return self;
}

#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.data setLength:0];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse && [httpResponse statusCode] == 200){
        self.totalLength = [httpResponse expectedContentLength];
    }
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    CGFloat progress = (CGFloat)[data length] / self.totalLength;
    self.progressBlock(progress);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.completedBlock(self.data);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.errorBlock(error);
}

@end
