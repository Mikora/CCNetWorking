//
//  NSString+CCNetworkingMethod.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "NSString+CCNetworkingMethod.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (CCNetworkingMethod)

- (NSString*)CC_md5{
    
    NSData* inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
    CC_MD5([inputData bytes], (unsigned int)[inputData length], outputData);
    
    NSMutableString* hashStr = [NSMutableString string];
    int i = 0;
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
        [hashStr appendFormat:@"%02x", outputData[i]];
    
    return hashStr;
}

@end
