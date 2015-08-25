//
//  CCServiceFactory.h
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import <Foundation/Foundation.h>
#import "CCService.h"

@interface CCServiceFactory : NSObject

+ (instancetype)sharedInstance;

- (CCService<CCServiceProtocol>*)serviceWithIdentifier:(NSString*)identifier;

@end
