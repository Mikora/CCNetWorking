//
//  CCServiceBase.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "CCServiceBase.h"

@interface CCServiceBase()


@property (nonatomic,assign) BOOL isOnline;

@property (nonatomic,strong) NSString *offlineApiBaseUrl;
@property (nonatomic,strong) NSString *onlineApiBaseUrl;

@property (nonatomic,strong) NSString *offlineApiVersion;
@property (nonatomic,strong) NSString *onlineApiVersion;

@property (nonatomic,strong) NSString *offlinePublicKey;
@property (nonatomic,strong) NSString *onlinePublicKey;

@property (nonatomic,strong) NSString *offlinePrivateKey;
@property (nonatomic,strong) NSString *onlinePrivateKey;

@end


@implementation CCServiceBase
#pragma mark - getters and setters

- (BOOL)isOnline{
    return YES;
}

- (NSString *)offlineApiBaseUrl{
    return @"http://xxx.xxx.com";
}

- (NSString *)onlineApiBaseUrl{
    return @"http://xxx.xxx.com";
}

- (NSString *)offlineApiVersion{
    return @"/api/v6";
}

- (NSString *)onlineApiVersion{
    return @"/api/v6";
}

- (NSString *)onlinePrivateKey{
    return @"123";
}

- (NSString *)onlinePublicKey{
    return @"321";
}

@end
