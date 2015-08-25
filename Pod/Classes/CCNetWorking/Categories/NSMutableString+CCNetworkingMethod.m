//
//  NSMutableString+CCNetworkingMethod.m
//  Pods
//
//  Created by 黄成 on 15/8/12.
//
//

#import "NSMutableString+CCNetworkingMethod.h"
#import "NSObject+CCNetworkingMethod.h"

@implementation NSMutableString (CCNetworkingMethod)

- (void)appendUrlRequest:(NSURLRequest *)request{
    [self appendFormat:@"\n HTTP URL: %@\n",request.URL];
    [self appendFormat:@"\n HTTP Header: %@\n",request.allHTTPHeaderFields?request.allHTTPHeaderFields:@"N/A"];
    [self appendFormat:@"\n\nHTTP Body:\n\t%@", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] CC_defaultValue:@"\t\t\t\tN/A"]];
}

@end
