//
//  CCNetWorkingConfig.h
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#ifndef Pods_CCNetWorkingConfig_h
#define Pods_CCNetWorkingConfig_h


typedef NS_ENUM(NSInteger, CCAppType) {
    CCAppTypeDemo,
    CCAppTypeDemo1
};

typedef NS_ENUM(NSUInteger, CCURLResponseStatus)
{
    CCURLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的RTApiBaseManager来决定。
    CCURLResponseStatusErrorTimeout,
    CCURLResponseStatusErrorNoNetwork // 默认除了超时以外的错误都是无网络错误。
};

static NSString *CCUDIDName = @"Demo";//查询udid
static NSString *CCKeychainServiceName = @"com.demo";
static NSString *CCPasteboardType = @"DemoContent";

static BOOL kDEBUG = YES;
static NSTimeInterval kCCNetWorkingTimeoutSeconds = 20.0f;

static BOOL kCCShouldCache = YES;
static NSTimeInterval kCCCacheOutdateTimeSeconds = 300; // 5分钟的cache过期时间
static NSUInteger kCCCacheCountLimit = 1000; // 最多1000条cache
#endif
