//
//  CCApiLogger.h
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import <Foundation/Foundation.h>
#import "CCURLResponse.h"
#import "CCService.h"
#import "CCApiLoggerConfig.h"

@interface CCApiLogger : NSObject

@property (nonatomic,strong ,readonly) CCApiLoggerConfig *configParams;

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName service:(CCService *)service requestParams:(id)requestParams httpMethod:(NSString *)httpMethod;
+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error;
+ (void)logDebugInfoWithCachedResponse:(CCURLResponse *)response methodName:(NSString *)methodName serviceIdentifier:(CCService *)service;

+ (instancetype)sharedInstance;
- (void)logWithActionCode:(NSString *)actionCode params:(NSDictionary *)params;

@end
