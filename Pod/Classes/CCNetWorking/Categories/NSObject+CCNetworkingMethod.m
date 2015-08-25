//
//  NSObject+CCNetworkingMethod.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "NSObject+CCNetworkingMethod.h"

@implementation NSObject (CCNetworkingMethod)


- (id)CC_defaultValue:(id)defaultData{
    
    if (![defaultData isKindOfClass:[self class]]) {
        return defaultData;
    }
    
    if ([self CC_isEmptyObject]) {
        return defaultData;
    }
    
    return self;
}
- (BOOL)CC_isEmptyObject{
    
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }
    
    return NO;
}

@end
