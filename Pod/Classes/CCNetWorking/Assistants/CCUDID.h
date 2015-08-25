//
//  CCUDID.h
//  Pods
//
//  Created by 黄成 on 15/8/14.
//
//

#import <Foundation/Foundation.h>

@interface CCUDID : NSObject

+ (instancetype)sharedInstance;

- (NSString*)UDID;

- (void)saveUDID:(NSString*)udid;

@end
