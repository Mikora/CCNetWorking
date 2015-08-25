//
//  CCCache.m
//  Pods
//
//  Created by 黄成 on 15/8/13.
//
//

#import "CCCache.h"
#import "NSDictionary+CCNetworkingMethods.h"
#import "CCNetWorkingConfig.h"

@interface CCCache ()

@property (nonatomic,strong) NSCache *cache;

@end

@implementation CCCache

#pragma mark - getter and setter

- (NSCache *)cache{
    if (_cache == nil) {
        _cache = [[NSCache alloc]init];
        _cache.countLimit = kCCCacheCountLimit;
    }
    return _cache;
}

#pragma maek - life cycle

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static CCCache *sharedCache;
    dispatch_once(&onceToken, ^{
        sharedCache = [[CCCache alloc]init];
    });
    return sharedCache;
}

#pragma mark - public method

- (NSData *)fetchCachedDataWithServiceIdentifier:(NSString *)serviceIdentifier methodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams{
    return [self fetchCachedDataWithKey:[self keyWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:requestParams]];
}

- (void)saveCacheWithData:(NSData *)cacheData serviceIdentifier:(NSString *)serviceIdentifier methodName:(NSString *)methdName requestParams:(NSDictionary *)requestParams{
    [self saveCacheWithData:cacheData key:[self keyWithServiceIdentifier:serviceIdentifier methodName:methdName requestParams:requestParams]];
}

- (void)deleteCacheWithServiceIdentifier:(NSString *)serviceIdentifier methodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams{
    [self deleteCacheWithKey:[self keyWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:requestParams]];
}

- (NSData *)fetchCachedDataWithKey:(NSString *)key{
    CCCacheObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject.isOutdated || cachedObject.isEmpty) {
        return nil;
    }
    return cachedObject.content;
}

- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key{
    CCCacheObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject == nil) {
        cachedObject = [[CCCacheObject alloc]init];
    }
    [cachedObject updateContent:cachedData];
    [self.cache setObject:cachedObject forKey:key];
}

- (void)deleteCacheWithKey:(NSString *)key{
    [self.cache removeObjectForKey:key];
}

- (void)clean{
    [self.cache removeAllObjects];
}

- (NSString *)keyWithServiceIdentifier:(NSString *)serviceIdentifier methodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams{
    return [NSString stringWithFormat:@"%@%@%@",serviceIdentifier,methodName,[requestParams CC_urlParamsStringSignature:NO]];
}

@end
