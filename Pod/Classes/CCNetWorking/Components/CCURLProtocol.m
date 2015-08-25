//
//  CCURLProtocol.m
//  Pods
//
//  Created by 黄成 on 15/8/21.
//
//

#import "CCURLProtocol.h"

@implementation CCURLProtocol


+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    if ([NSURLProtocol propertyForKey:@"123456" inRequest:request]) {
        return NO;
    }
    NSString *scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||[scheme caseInsensitiveCompare:@"https"] == NSOrderedSame ||[scheme caseInsensitiveCompare:@"ws"] == NSOrderedSame ||[scheme caseInsensitiveCompare:@"wss"] == NSOrderedSame ) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSString *scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:@"https"]) {
        
        return request;
    }
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading{
    NSMutableURLRequest *request = [[self request]mutableCopy];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:nil];
}

- (void)stopLoading{
    [self.connection cancel];
    self.connection = nil;
}
@end
