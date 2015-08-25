//
//  CCURLResponse.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "CCURLResponse.h"
#import "NSObject+CCNetworkingMethod.h"
#import "NSURLRequest+CCNetworkingMethods.h"

@interface CCURLResponse()

@property (nonatomic,assign,readwrite)  CCURLResponseStatus status;
@property (nonatomic,copy,readwrite)    NSString            *contentString;
@property (nonatomic,copy,readwrite)    id                  content;
@property (nonatomic,copy,readwrite)    NSURLRequest        *request;
@property (nonatomic,assign,readwrite)  NSInteger           requestID;
@property (nonatomic,copy,readwrite)    NSData              *responseData;
@property (nonatomic,assign,readwrite)  BOOL                isCache;

@end

@implementation CCURLResponse

- (instancetype)initWithResponseString:(NSString *)responseString requestID:(NSNumber *)requestID request:(NSURLRequest *)request responseData:(NSData *)responseData status:(CCURLResponseStatus)status{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        self.status = status;
        self.requestParams = request.requestParams;
        self.requestID = [requestID integerValue];
        self.request = request;
        self.responseData = responseData;
        self.isCache = NO;
    }
    return self;
}

- (instancetype)initWithResponseString:(NSString *)responseString requestID:(NSNumber *)requestID request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.status = [self responseStatusWithError:error];
        self.requestID = [requestID integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        if (responseData) {
            self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        }else{
            self.content = nil;
        }
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        self.contentString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        self.status = [self responseStatusWithError:nil];
        self.requestID = 0;
        self.request = nil;
        self.responseData = [data copy];
        self.content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        self.isCache = YES;
    }
    return self;
}

#pragma mark - private method

- (CCURLResponseStatus)responseStatusWithError:(NSError*)error{
    if (error) {
        CCURLResponseStatus result = CCURLResponseStatusErrorNoNetwork;
        if (error.code == NSURLErrorTimedOut) {
            result = CCURLResponseStatusErrorNoNetwork;
        }
        return result;
    }else{
        return CCURLResponseStatusSuccess;
    }
}
@end
