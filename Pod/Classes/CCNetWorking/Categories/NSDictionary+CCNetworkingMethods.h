//
//  NSDictionary+CCNetworkingMethods.h
//  Pods
//
//  Created by 黄成 on 15/8/12.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CCNetworkingMethods)

- (NSString *)CC_urlParamsStringSignature:(BOOL)isForSignature;
- (NSString *)CC_jsonString;
- (NSArray *)CC_transformedUrlParamsArraySignature:(BOOL)isForSignature;

@end
