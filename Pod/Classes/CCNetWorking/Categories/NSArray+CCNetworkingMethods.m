//
//  NSArray+CCNetworkingMethods.m
//  Pods
//
//  Created by 黄成 on 15/8/12.
//
//

#import "NSArray+CCNetworkingMethods.h"

@implementation NSArray (CCNetworkingMethods)

- (NSString *)CC_paramsString{
    NSMutableString *paramString = [[NSMutableString alloc]init];
    NSArray *sortParams = [self sortedArrayUsingSelector:@selector(compare:)];
    [sortParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([paramString length] == 0) {
            [paramString appendFormat:@"%@",obj];
        }else{
            [paramString appendFormat:@"&%@",obj];
        }
    }];
    return paramString;
}

- (NSString *)CC_jsonString{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}


@end
