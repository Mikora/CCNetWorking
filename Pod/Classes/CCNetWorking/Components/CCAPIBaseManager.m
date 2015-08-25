//
//  CCAPIBaseManager.m
//  Pods
//
//  Created by 黄成 on 15/8/13.
//
//

#import "CCAPIBaseManager.h"
#import "CCNetworking.h"

#define CCApiCall(REQUEST_METHOD,REQUEST_ID)\
{\
    REQUEST_ID = [[CCApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:apiParams serviceIdentifier:self.child.serviceType methodName:self.child.methodName success:^(CCURLResponse *response) { \
            [self successedOnCallingAPI:response];                                          \
        } fail:^(AIFURLResponse *response) {                                                \
            [self failedOnCallingAPI:response withErrorType:CCAPIManagerErrorTypeDefault];  \
        }];                                                                                 \
    [self.requestIdList addObject:@(REQUEST_ID)];\
}\


@interface CCAPIBaseManager ()

@property (nonatomic,strong,readwrite) id fetchRawData;
@property (nonatomic,copy,readwrite) NSString *errorMessage;
@property (nonatomic,readwrite) CCAPIManagerErrorType errorType;
@property (nonatomic,strong) NSMutableArray *requestIdList;
@property (nonatomic,strong) CCCache *cache;

@end

@implementation CCAPIBaseManager


- (NSMutableArray*)requestIdList{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc]init];
    }
    return _requestIdList;
}

- (CCCache*)cache{
    if (_cache == nil) {
        _cache = [CCCache sharedInstance];
    }
    return _cache;
}

- (BOOL)isReachable{
    BOOL isReachability = [[CCAppContext sharedInstance]isReachable];
    if (!isReachability) {
        self.errorType = CCAPIManagerErrorTypeNoNetWork;
    }
    return isReachability;
}

#pragma mark - life cycle

- (instancetype)init{
    self = [super init];
    if (self) {
        _delegate = nil;
        _validator = nil;
        _paramSource = nil;
        _fetchRawData = nil;
        _errorMessage = nil;
        _errorType = CCAPIManagerErrorTypeDefault;
        if ([self conformsToProtocol:@protocol(CCAPIManager)]) {
            self.child = (id<CCAPIManager>)self;
        }
    }
    return self;
}

- (void)dealloc{
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - public method

- (void)cancelAllRequests{
    [[CCApiProxy sharedInstance]cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestWithRequestID:(NSInteger)requestID{
    [self removeRequestIdWithRequestID:requestID];
    [[CCApiProxy sharedInstance]cancelRequestWithRequestID:@(requestID)];
}

- (id)fetchDataWithReformer:(id<CCAPIManagerCallbackDataReformer>)reformer{
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        resultData = [reformer manager:self reformData:self.fetchRawData];
    }else{
        resultData = [self.fetchRawData mutableCopy];
    }
    return  resultData;
}

#pragma mark - calling api

- (NSInteger)loadData{
    NSDictionary *params = [self.paramSource paramsForApi:self];
    NSInteger requestID = [self loadDataWithParams:params];
    return requestID;
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params{
    NSInteger requestId = 0;
    NSDictionary *apiParams = [self reformParams:params];
    if ([self shouldCallAPIWithParams:apiParams]) {
        if ([self.validator manager:self isCorrectWithParamsData:apiParams]) {
            
            // 先检查一下是否有缓存
            if ([self shouldCache] && [self hasCacheWithParams:apiParams]) {
                return 0;
            }
            if ([self isReachable]) {
                switch (self.child.requestType) {
                    case CCAPIManagerRequestTypeGet:{
                         requestId = [[CCApiProxy sharedInstance]callGETWithParams:apiParams serviceIdentifier:self.child.serviceType methodName:self.child.methodName success:^(CCURLResponse *response) {
                            [self successedOnCallingAPI:response];
                        } fail:^(CCURLResponse *response) {
                            [self failedOnCallingAPI:response withErrorType:CCAPIManagerErrorTypeDefault];
                        }];
                        [self.requestIdList addObject:@(requestId)];
                        
                    }break;
                    case CCAPIManagerRequestTypePost:{
                        
                        requestId = [[CCApiProxy sharedInstance]callPOSTWithParams:apiParams serviceIdentifier:self.child.serviceType methodName:self.child.methodName success:^(CCURLResponse *response) {
                            [self successedOnCallingAPI:response];
                        } fail:^(CCURLResponse *response) {
                            [self failedOnCallingAPI:response withErrorType:CCAPIManagerErrorTypeDefault];
                        }];
                        [self.requestIdList addObject:@(requestId)];
                    }break;
                    case CCAPIManagerRequestTypeRestGet:
                        //....
                        break;
                    case CCAPIManagerRequestTypeRestPost:
                        //...
                        break;
                    default:
                        break;
                }
                NSMutableDictionary *params = [apiParams mutableCopy];
                params[kCCAPIBaseManagerRequestID] = @(requestId);
                [self afterCallingAPIWithParams:params];
                return requestId;
            }else{
                [self failedOnCallingAPI:nil withErrorType:CCAPIManagerErrorTypeNoNetWork];
            }
        }else{
            [self failedOnCallingAPI:nil withErrorType:CCAPIManagerErrorTypeParamsError];
        }
    }
    return requestId;
}

#pragma mark - api callbacks

- (void)apiCallBack:(CCURLResponse *)response{
    if (response.status == CCURLResponseStatusSuccess) {
        [self successedOnCallingAPI:response];
    }else{
        [self failedOnCallingAPI:response withErrorType:CCAPIManagerErrorTypeTimeout];
    }
}

- (void)successedOnCallingAPI:(CCURLResponse *)response{
    if (response.content) {
        self.fetchRawData = [response.content copy];
    }else{
        self.fetchRawData = [response.responseData copy];
    }
    
    [self removeRequestIdWithRequestID:response.requestID];
    
    if ([self.validator manager:self isCorrectWithCallbackData:response.content]) {
        if (kCCShouldCache && ! response.isCache) {
            [self.cache saveCacheWithData:response.responseData serviceIdentifier:self.child.serviceType methodName:self.child.methodName requestParams:response.requestParams];
        }
        [self beforePerformSuccessWithResponse:response];
        [self.delegate managerCallApiDidSuccess:self];
        [self afterPerformSuccessWithResponse:response];
    }else{
        [self failedOnCallingAPI:response withErrorType:CCAPIManagerErrorTypeNoContent];
    }
}

- (void)failedOnCallingAPI:(CCURLResponse *)response withErrorType:(CCAPIManagerErrorType)errorType{
    self.errorType = errorType;
    [self removeRequestIdWithRequestID:response.requestID];
    [self beforePerformFailWithResponse:response];
    [self.delegate managerCallApiDidFailed:self];
    [self afterPerformFailWithResponse:response];
}

#pragma mark - method for interceptor


- (void)beforePerformSuccessWithResponse:(CCURLResponse *)response{
    self.errorType = CCAPIManagerErrorTypeSuccess;
    if (self!= self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResponse:)]) {
        [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
}

- (void)afterPerformSuccessWithResponse:(CCURLResponse *)response{
    self.errorType = CCAPIManagerErrorTypeSuccess;
    if (self!= self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (void)beforePerformFailWithResponse:(CCURLResponse *)response{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
}

- (void)afterPerformFailWithResponse:(CCURLResponse *)response{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    }else{
        return YES;
    }
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

#pragma mark - method for child

- (void)cleanData{
    IMP childIMP = [self.child methodForSelector:@selector(cleanData)];
    IMP selfIMP = [self methodForSelector:@selector(cleanData)];
    
    if (childIMP == selfIMP) {
        self.fetchRawData = nil;
        self.errorType = CCAPIManagerErrorTypeDefault;
        self.errorMessage = nil;
    }else{
        if ([self.child respondsToSelector:@selector(cleanData)]) {
            [self.child cleanData];
        }
    }
}

- (NSDictionary *)reformParams:(NSDictionary *)params{
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        // 如果child是继承得来的，那么这里就不会跑到，会直接跑子类中的IMP。
        // 如果child是另一个对象，就会跑到这里
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
}

- (BOOL)shouldCache{
    return kCCShouldCache;
}

#pragma mark - private mothod

- (void)removeRequestIdWithRequestID:(NSInteger)requestID{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storeRequestId in self.requestIdList ) {
        if ([storeRequestId integerValue] == requestID) {
            requestIDToRemove = storeRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
    
}

- (BOOL)hasCacheWithParams:(NSDictionary*)params{
    NSString *serviceIdentifier = self.child.serviceType;
    NSString *methodName = self.child.methodName;
    NSData *result = [self.cache fetchCachedDataWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:params];
    if (result ==nil) {
        return NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CCURLResponse *response = [[CCURLResponse alloc]initWithData:result];
        response.requestParams = params;
        [CCApiLogger logDebugInfoWithCachedResponse:response methodName:methodName serviceIdentifier:[[CCServiceFactory sharedInstance]serviceWithIdentifier:serviceIdentifier]];
        [self successedOnCallingAPI:response];
    });
    return YES;
}
@end
