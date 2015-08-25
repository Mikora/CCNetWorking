//
//  CCApiProxy.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "CCApiProxy.h"
#import "AFHTTPRequestOperationManager.h"
#import "CCRequestGenerator.h"
#import "CCApiLogger.h"

static NSString * const kCCApiProxyDispatchItemKeyCallbackSuccess = @"kCCApiProxyDispatchItemKeyCallbackSuccess";
static NSString * const kCCApiProxyDispatchItemKeyCallbackFail = @"kCCApiProxyDispatchItemKeyCallbackFail";

@interface CCApiProxy ()

@property (nonatomic,strong) NSMutableDictionary *dispatchTable;
@property (nonatomic,strong) NSNumber *recordRequestID;

@property (nonatomic,strong) AFHTTPRequestOperationManager *operationManager;

@end

@implementation CCApiProxy



+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static CCApiProxy *shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[CCApiProxy alloc]init];
    });
    return shareInstance;
}

/*
 * 方法 : GET
 * 参数 : params
 * serviceIdentifier : 根据identifier选择处理返回数据的model
 * methodName :/v1api/methodName
 */
- (NSInteger)callGETWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)serviceIdentifier methodName:(NSString *)methodName success:(CCProxyCallBack)success fail:(CCProxyCallBack)fail{
    
    NSURLRequest *request = [[CCRequestGenerator sharedInstance]generateGETRequestWithServiceIdentifier:serviceIdentifier requestParams:params methodName:methodName];
    NSNumber *requestID = [self callApiWithRequest:request success:success fail:fail];
    return [requestID integerValue];
}
- (NSInteger)callPOSTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)serviceIdentifier methodName:(NSString *)methodName success:(CCProxyCallBack)success fail:(CCProxyCallBack)fail{
    
    NSURLRequest *request = [[CCRequestGenerator sharedInstance] generatePOSTRequestWithServiceIdentifier:serviceIdentifier requestParams:params methodName:methodName];
    NSNumber *requestID = [self callApiWithRequest:request success:success fail:fail];
    return [requestID integerValue];
}

- (NSInteger)callRestfulGETWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)serviceIdentifier methodName:(NSString *)methodName success:(CCProxyCallBack)success fail:(CCProxyCallBack)fail{
    
    NSURLRequest *request = [[CCRequestGenerator sharedInstance] generateRestfulGETRequestWithServiceIdentifier:serviceIdentifier requestParams:params methodName:methodName];
    NSNumber *requestID = [self callApiWithRequest:request success:success fail:fail];
    
    return [requestID integerValue];
}
- (NSInteger)callRestfulPOSTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)serviceIdentifier methodName:(NSString *)methodName success:(CCProxyCallBack)success fail:(CCProxyCallBack)fail{
    
    NSURLRequest *request = [[CCRequestGenerator sharedInstance]generateRestfulPOSTRequestWithServiceIdentifier:serviceIdentifier requestParams:params methodName:methodName];
    NSNumber *requestID = [self callApiWithRequest:request success:success fail:fail];
    
    return [requestID integerValue];
}


- (NSInteger)callGoogleMapAPIWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)serviceIdentifier success:(CCProxyCallBack)success fail:(CCProxyCallBack)fail{
    
    NSURLRequest *request = [[CCRequestGenerator sharedInstance]generateGoolgeMapAPIRequestWithParams:params serviceIdentifier:serviceIdentifier];
    NSNumber *requestID = [self callApiWithRequest:request success:success fail:fail];
    
    return [requestID integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID{
    NSOperation *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList{
    for (NSNumber *requestID in requestIDList) {
        [self cancelRequestWithRequestID:requestID];
    }
}

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(CCProxyCallBack)success fail:(CCProxyCallBack)fail{
    
    NSNumber *requestID = [self generateRequestId];
    
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperation *httpRequestOperation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AFHTTPRequestOperation *storeOperation = weakSelf.dispatchTable[requestID];
        if (storeOperation ==nil) {
            return ;
        } else {
            [weakSelf.dispatchTable removeObjectForKey:requestID];
        }//移除完成的请求
        
        [CCApiLogger logDebugInfoWithResponse:operation.response resposeString:operation.responseString request:operation.request error:NULL];
        //打印日志
        
        CCURLResponse *response = [[CCURLResponse alloc]initWithResponseString:operation.responseString requestID:requestID request:operation.request responseData:operation.responseData status:CCURLResponseStatusSuccess];
        
        success?success(response):nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFHTTPRequestOperation *storeOperation = weakSelf.dispatchTable[requestID];
        if (storeOperation == nil) {
            return;
        } else {
            [weakSelf.dispatchTable removeObjectForKey:requestID];
        }
        
        CCURLResponse *response = [[CCURLResponse alloc]initWithResponseString:operation.responseString requestID:requestID request:operation.request responseData:operation.responseData error:error];
        fail?fail(response):nil;
    }];
    
    self.dispatchTable[requestID] = httpRequestOperation;
    [[self.operationManager operationQueue]addOperation:httpRequestOperation];
    return requestID;
}
#pragma mark -- getter and setter

- (NSMutableDictionary *)dispatchTable{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc]init];
    }
    return _dispatchTable;
}

- (AFHTTPRequestOperationManager *)operationManager{
    if (_operationManager == nil) {
        _operationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:nil];
        _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _operationManager;
}

- (NSNumber*)generateRequestId{
    if(_recordRequestID == nil){
        _recordRequestID = @(1);
    }else{
        if ([_recordRequestID integerValue] == NSIntegerMax) {
            _recordRequestID = @(1);
        }else{
            _recordRequestID = @([_recordRequestID integerValue]+1);
        }
    }
    return _recordRequestID;
}

@end
