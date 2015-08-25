//
//  CCCommonParamsGenerator.m
//  Pods
//
//  Created by 黄成 on 15/8/12.
//
//

#import "CCCommonParamsGenerator.h"
#import "CCAppContext.h"
#import "NSDictionary+CCNetworkingMethods.h"

@implementation CCCommonParamsGenerator

+ (NSDictionary *)commonParamsDictionary{
    CCAppContext *context = [CCAppContext sharedInstance];
    return @{@"cid":context.cityid,
             @"ostype":context.ostype,
             @"uuid":context.uuid,
             @"appName":context.appName,
             @"cfBundleVersion":context.cfBundleVersion,
             @"from":context.from,
             @"model":context.model,
             @"macAddr":context.macAddr,
             @"systemName":context.systemName,
             @"channelID":context.channelID,
             @"nowtime":context.nowtime,
             @"systemVersion":context.systemVersion};
}
+ (NSDictionary *)commonParamsDictionaryForLog{
    CCAppContext *context = [CCAppContext sharedInstance];
    return @{@"guid":context.guid,
             @"net":context.net,
             @"ver":context.ver,
             @"ip":context.ip,
             @"macAddr":context.macAddr,
             @"geo":context.geo,
             @"userid":context.uid,
             @"chatid":context.chatid,
             @"ccid":context.ccid,
             @"geoCityid":context.geoCityid,
             @"platform":context.platform,
             @"systemVersion":context.systemVersion,
             @"appName":context.appName,
             @"channelID":context.channelID,
             @"nowtime":context.nowtime,
             @"pmodel":context.pmodel
             };
}
@end
