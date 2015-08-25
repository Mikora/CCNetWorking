//
//  CCRequestGenerator.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "CCRequestGenerator.h"
#import "CCNetWorkingConfig.h"
#import "AFNetworking.h"
#import "CCService.h"
#import "CCServiceFactory.h"
#import "CCCommonParamsGenerator.h"
#import "CCSignatureGenerator.h"
#import "NSURLRequest+CCNetworkingMethods.h"
#import "NSDictionary+CCNetworkingMethods.h"
#import "CCApiLogger.h"

@interface CCRequestGenerator()

@property (nonatomic,strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation CCRequestGenerator


+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static CCRequestGenerator *shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[CCRequestGenerator alloc]init];
    });
    return shareInstance;
}

- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName{
    
    CCService *service = [[CCServiceFactory sharedInstance]serviceWithIdentifier:serviceIdentifier];
    /*
     对数据进行签名
     */
    //url 示例： niu.souche.com/v5/api/city
    
    NSMutableDictionary *allparams = [NSMutableDictionary dictionaryWithDictionary:[CCCommonParamsGenerator commonParamsDictionary]];
    allparams[@"api_key"] = service.publicKey;
    [allparams addEntriesFromDictionary:requestParams];
    NSString *signature = [CCSignatureGenerator signGetWithSigParams:allparams methodName:methodName apiVersion:service.apiVersion privateKey:service.privateKey publicKey:service.publicKey];
    allparams[@"sig"] = signature;
    
    /*
     可以做签名和安全
     */
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params addEntriesFromDictionary:allparams];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",service.apiBaseUrl,service.apiVersion,methodName];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:urlString parameters:params error:NULL];
    
    
    request.timeoutInterval = kCCNetWorkingTimeoutSeconds;
    request.requestParams = requestParams;
    [CCApiLogger logDebugInfoWithRequest:request apiName:methodName service:service requestParams:requestParams httpMethod:@"GET"];
    return request;
    
}
- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName{
    CCService *service = [[CCServiceFactory sharedInstance]serviceWithIdentifier:serviceIdentifier];
    NSString *signature = [CCSignatureGenerator signPostWithApiParams:requestParams privateKey:service.privateKey publicKey:service.publicKey];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"apikey"] = service.publicKey;
    params[@"sig"] = signature;
    [params addEntriesFromDictionary:[CCCommonParamsGenerator commonParamsDictionary]];
    [params addEntriesFromDictionary:requestParams];
    
    //待修改
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",service.apiBaseUrl,service.apiVersion,methodName];
    
    NSURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:params error:NULL];
    request.requestParams = requestParams;
    
    [CCApiLogger logDebugInfoWithRequest:request apiName:methodName service:service requestParams:requestParams httpMethod:@"POST"];
    
    return request;
}

- (NSURLRequest *)generateRestfulGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName{
    
    NSMutableDictionary *allparams = [NSMutableDictionary dictionaryWithDictionary:[CCCommonParamsGenerator commonParamsDictionary]];
    [allparams addEntriesFromDictionary:requestParams];
    
    CCService *service = [[CCServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *signature = [CCSignatureGenerator signRestfulGetWithAllParams:allparams methodName:methodName apiVersion:service.apiVersion privateKey:service.privateKey];
    
    NSDictionary *requestHeader = [self commonHeaderWithService:service signature:signature];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",service.apiBaseUrl,service.apiVersion,methodName];
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:urlString parameters:allparams error:NULL];
    request.HTTPMethod = @"GET";
    [requestHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forKey:key];
    }];
    request.requestParams = requestParams;
    
    [CCApiLogger logDebugInfoWithRequest:request apiName:methodName service:service requestParams:requestParams httpMethod:@"rest get"];
    return request;
}
- (NSURLRequest *)generateRestfulPOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName{
    
    CCService *service = [[CCServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSDictionary *commonParams = [CCCommonParamsGenerator commonParamsDictionary];
    NSString *signature = [CCSignatureGenerator signRestfulPOSTWithApiParams:requestParams commonParams:commonParams methodName:methodName apiVersion:service.apiVersion privateKey:service.privateKey];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?&%@", service.apiBaseUrl, service.apiVersion, methodName, [commonParams CC_urlParamsStringSignature:NO]];
    
    NSDictionary *restfulHeader = [self commonHeaderWithService:service signature:signature];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kCCNetWorkingTimeoutSeconds];
    request.HTTPMethod = @"POST";
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:NULL];
    request.requestParams = requestParams;
    [CCApiLogger logDebugInfoWithRequest:request apiName:methodName service:service requestParams:requestParams httpMethod:@"RESTful POST"];
    return request;
}

- (NSURLRequest *)generateGoolgeMapAPIRequestWithParams:(NSDictionary *)requestParams serviceIdentifier:(NSString *)serviceIdentifier{
    
    CCService *service = [[CCServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", service.apiBaseUrl, service.apiVersion]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kCCNetWorkingTimeoutSeconds];
    [request setValue:@"zh-CN,zh;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
    request.requestParams = requestParams;
    [CCApiLogger logDebugInfoWithRequest:request apiName:@"Google Map API" service:service requestParams:requestParams httpMethod:@"GET"];
    return request;
}

#pragma mark - private Method

//这一段可以加在request的header里面，使所有请求头格式一样
- (NSDictionary*)commonHeaderWithService:(CCService*)service signature:(NSString*)signature{
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    [headerDic setValue:signature forKey:@"sig"];
    [headerDic setValue:service.publicKey forKey:@"key"];
    [headerDic setValue:@"application/json" forKey:@"Accept"];
    [headerDic setValue:@"application/json" forKey:@"Content-Type"];
    NSDictionary *loginResult = [[NSUserDefaults standardUserDefaults] objectForKey:@""];//用户token
    if (loginResult[@"auth_token"]) {
        [headerDic setValue:loginResult[@"auth_token"] forKey:@"AuthToken"];
    }
    return headerDic;
}

#pragma mark - getter

- (AFHTTPRequestSerializer *)httpRequestSerializer{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = kCCNetWorkingTimeoutSeconds;
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}

@end
