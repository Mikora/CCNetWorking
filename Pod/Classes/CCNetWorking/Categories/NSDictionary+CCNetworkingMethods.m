//
//  NSDictionary+CCNetworkingMethods.m
//  Pods
//
//  Created by 黄成 on 15/8/12.
//
//

#import "NSDictionary+CCNetworkingMethods.h"
#import "NSArray+CCNetworkingMethods.h"

@implementation NSDictionary (CCNetworkingMethods)

- (NSString *)CC_urlParamsStringSignature:(BOOL)isForSignature{
    NSArray *sortArray = [self CC_transformedUrlParamsArraySignature:isForSignature];
    return [sortArray CC_paramsString];
}

- (NSString *)CC_jsonString{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSArray *)CC_transformedUrlParamsArraySignature:(BOOL)isForSignature{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@",obj];
        }
        if (!isForSignature) {
            obj = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)obj, NULL, (CFStringRef)@"!*'();:=+$,/?%#[]", kCFStringEncodingUTF8));
        }
        if ([obj length] > 0 ) {
            [result addObject:[NSString stringWithFormat:@"%@=%@",key,obj]];
        }
    }];
    NSArray *sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return sortedResult;
}

@end
