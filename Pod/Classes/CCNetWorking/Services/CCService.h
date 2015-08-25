//
//  CCService.h
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import <Foundation/Foundation.h>

@protocol CCServiceProtocol <NSObject>

@property (nonatomic,readonly) BOOL isOnline;

@property (nonatomic,readonly) NSString *offlineApiBaseUrl;
@property (nonatomic,readonly) NSString *onlineApiBaseUrl;

@property (nonatomic,readonly) NSString *offlineApiVersion;
@property (nonatomic,readonly) NSString *onlineApiVersion;

@property (nonatomic,readonly) NSString *offlinePublicKey;
@property (nonatomic,readonly) NSString *onlinePublicKey;

@property (nonatomic,readonly) NSString *offlinePrivateKey;
@property (nonatomic,readonly) NSString *onlinePrivateKey;

@end;

@interface CCService : NSObject

@property (nonatomic,strong,readonly) NSString *publicKey;
@property (nonatomic,strong,readonly) NSString *privateKey;
@property (nonatomic,strong,readonly) NSString *apiBaseUrl;
@property (nonatomic,strong,readonly) NSString *apiVersion;

@property (nonatomic,weak) id<CCServiceProtocol> child;

@end
