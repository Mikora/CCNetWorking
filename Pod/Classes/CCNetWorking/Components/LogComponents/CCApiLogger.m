//
//  CCApiLogger.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "CCApiLogger.h"
#import "CCAppContext.h"
#import "CCCommonParamsGenerator.h"
#import "NSDictionary+CCNetworkingMethods.h"
#import "NSArray+CCNetworkingMethods.h"
#import "NSObject+CCNetworkingMethod.h"
#import "NSMutableString+CCNetworkingMethod.h"
#import "CCApiProxy.h"

@interface CCApiLogger ()

@property (nonatomic,strong,readwrite) CCApiLoggerConfig *configParams;

@end

@implementation CCApiLogger

- (instancetype)init{
    self = [super init];
    if (self) {
        self.configParams = [[CCApiLoggerConfig alloc]init];
        [self.configParams configWithAppType:[CCAppContext sharedInstance].appType];
    }
    return self;
}

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static CCApiLogger *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCApiLogger alloc]init];
    });
    return sharedInstance;
}

//调用完成回调服务器，打印日志
- (void)logWithActionCode:(NSString *)actionCode params:(NSDictionary *)params{
    NSMutableDictionary *actionDict = [[NSMutableDictionary alloc]init];
    actionDict[@"action"] = actionCode;
    [actionDict addEntriesFromDictionary:params];
    [actionDict addEntriesFromDictionary:[CCCommonParamsGenerator commonParamsDictionaryForLog]];
    NSDictionary *logJsonDict = @{self.configParams.sendActionKey:[@[actionDict] CC_jsonString]};
    
    [[CCApiProxy sharedInstance]callPOSTWithParams:logJsonDict serviceIdentifier:self.configParams.serviceType methodName:self.configParams.sendActionMethod success:nil fail:nil];
}

//网络请求开始，打印请求详情

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName service:(CCService *)service requestParams:(id)requestParams httpMethod:(NSString *)httpMethod{
    BOOL isOnline = NO;
    if ([service respondsToSelector:@selector(isOnline)]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[service methodSignatureForSelector:@selector(isOnline)]];
        invocation.target = service;
        invocation.selector = @selector(isOnline);
        [invocation invoke];
        [invocation getReturnValue:&isOnline];
    }
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"API Name:\t\t%@\n", [apiName CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Method:\t\t\t%@\n", [httpMethod CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Version:\t\t%@\n", [service.apiVersion CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Service:\t\t%@\n", [service class]];
    [logString appendFormat:@"Status:\t\t\t%@\n", isOnline ? @"online" : @"offline"];
    [logString appendFormat:@"Public Key:\t\t%@\n", [service.publicKey CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Private Key:\t%@\n", [service.privateKey CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Params:\n%@", requestParams];
    
    [logString appendUrlRequest:request];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
    
#ifdef kDEBUG
    
#endif
}

// 请求回调的时候，打印回调详情
+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error{
    
    BOOL shouldLogError = error ? YES : NO;
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                        API Response                        =\n==============================================================\n\n"];
    
    [logString appendFormat:@"Status:\t%ld\t(%@)\n\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"Content:\n\t%@\n\n", responseString];
    if (shouldLogError) {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    
    [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
    
    [logString appendUrlRequest:request];
    
    [logString appendFormat:@"\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n"];
    
    NSLog(@"%@", logString);
#ifdef kDEBUG
    
#endif
}

//本地缓存读取，打印缓存信息

+ (void)logDebugInfoWithCachedResponse:(CCURLResponse *)response methodName:(NSString *)methodName serviceIdentifier:(CCService *)service{
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                      Cached Response                       =\n==============================================================\n\n"];
    
    [logString appendFormat:@"API Name:\t\t%@\n", [methodName CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Version:\t\t%@\n", [service.apiVersion CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Service:\t\t%@\n", [service class]];
    [logString appendFormat:@"Public Key:\t\t%@\n", [service.publicKey CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Private Key:\t%@\n", [service.privateKey CC_defaultValue:@"N/A"]];
    [logString appendFormat:@"Method Name:\t%@\n", methodName];
    [logString appendFormat:@"Params:\n%@\n\n", response.requestParams];
    [logString appendFormat:@"Content:\n\t%@\n\n", response.contentString];
    
    [logString appendFormat:@"\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n"];
    NSLog(@"%@", logString);
#ifdef kDEBUG
    
#endif
}

@end
