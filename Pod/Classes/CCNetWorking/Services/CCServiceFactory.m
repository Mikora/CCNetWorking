//
//  CCServiceFactory.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "CCServiceFactory.h"
#import "CCService.h"
#import "CCServiceBase.h"

@interface CCServiceFactory()

@property (nonatomic,strong) NSMutableDictionary *serviceStorage;

@end

@implementation CCServiceFactory

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static CCServiceFactory *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCServiceFactory alloc]init];
    });
    return sharedInstance;
}


- (CCService<CCServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier{
    if (self.serviceStorage[identifier] == nil) {
        self.serviceStorage[identifier] = [self addServiceWithIdentifier:identifier];
    }
    return self.serviceStorage[identifier];
}


#pragma mark - private methods

- (CCService<CCServiceProtocol>*)addServiceWithIdentifier:(NSString*)identifier{
    Class serviceClass = NSClassFromString(identifier);
    if (serviceClass) {
        return [[serviceClass alloc]init];
    }
    return [[CCServiceBase alloc]init];
}

#pragma mark - getter and setter

- (NSMutableDictionary *)serviceStorage{
    if (_serviceStorage == nil) {
        _serviceStorage = [[NSMutableDictionary alloc]init];
    }
    return _serviceStorage;
}

@end
