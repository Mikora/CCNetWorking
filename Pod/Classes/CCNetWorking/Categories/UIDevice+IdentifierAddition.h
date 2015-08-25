//
//  UIDevice+IdentifierAddition.h
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (IdentifierAddition)

- (NSString *) uuid;
- (NSString *) udid;
- (NSString *) macaddress;
- (NSString *) macaddressMD5;
- (NSString *) machineType;
- (NSString *) ostype;//显示“ios6，ios5”，只显示大版本号
- (NSString *) createUUID;

@end
