//
//  CCLoginManager.m
//  CCNetWorking
//
//  Created by 黄成 on 15/8/13.
//  Copyright (c) 2015年 huangcheng. All rights reserved.
//

#import "CCLoginManager.h"

@interface CCLoginManager()<CCAPIManagerValidator,CCAPIManager>

@end

@implementation CCLoginManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.validator = self;
        self.child = self;
    }
    return self;
}


- (NSDictionary *)reformParams:(NSDictionary *)param{
    return param;
}

- (BOOL)manager:(CCAPIBaseManager *)manager isCorrectWithParamsData:(NSDictionary *)data{
    return YES;
}

- (BOOL)manager:(CCAPIBaseManager *)manager isCorrectWithCallbackData:(NSDictionary *)data{
    return YES;
}

- (NSString *)methodName{
    return @"auctions";
}

- (NSString *)serviceType{
    
    return @"CCServiceBase";
}

- (CCAPIManagerRequestType)requestType{
    return 1;
}

-(BOOL)shouldCache{
    return NO;
}

@end
