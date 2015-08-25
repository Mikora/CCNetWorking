//
//  NSURLRequest+CCNetworkingMethods.m
//  Pods
//
//  Created by 黄成 on 15/8/13.
//
//

#import "NSURLRequest+CCNetworkingMethods.h"
#import <objc/runtime.h>

static void *CCNetwokingRequestParams;

@implementation NSURLRequest (CCNetworkingMethods)

- (void)setRequestParams:(NSDictionary *)requestParams{
    objc_setAssociatedObject(self, &CCNetwokingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary*)requestParams{
    return objc_getAssociatedObject(self, &CCNetwokingRequestParams);
}

@end
