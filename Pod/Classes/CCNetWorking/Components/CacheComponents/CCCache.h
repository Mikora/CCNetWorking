//
//  CCCache.h
//  Pods
//
//  Created by 黄成 on 15/8/13.
//
//

#import <Foundation/Foundation.h>
#import "CCCacheObject.h"

@interface CCCache : NSObject

+ (instancetype)sharedInstance;

- (NSString*)keyWithServiceIdentifier:(NSString*)serviceIdentifier
                           methodName:(NSString*)methodName
                        requestParams:(NSDictionary*)requestParams;

- (NSData*)fetchCachedDataWithServiceIdentifier:(NSString*)serviceIdentifier
                                    methodName:(NSString*)methodName
                                 requestParams:(NSDictionary*)requestParams;

- (void)saveCacheWithData:(NSData*)cacheData
        serviceIdentifier:(NSString*)serviceIdentifier
               methodName:(NSString*)methdName
            requestParams:(NSDictionary*)requestParams;

- (void)deleteCacheWithServiceIdentifier:(NSString*)serviceIdentifier
                              methodName:(NSString*)methodName
                           requestParams:(NSDictionary*)requestParams;

- (NSData*)fetchCachedDataWithKey:(NSString*)key;

- (void)saveCacheWithData:(NSData*)cachedData key:(NSString*)key;

- (void)deleteCacheWithKey:(NSString*)key;

- (void)clean;

@end
