//
//  CCAppContext.h
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import <Foundation/Foundation.h>
#import "CCNetWorkingConfig.h"

@interface CCAppContext : NSObject


//凡是未声明成readonly的都是需要在初始化的时候由外面给的

@property (nonatomic, copy) NSString *channelID;    //渠道号
@property (nonatomic, copy) NSString *appName;      //应用名称
@property (nonatomic, assign) CCAppType appType;

@property (nonatomic, copy, readonly) NSString *cityid;          //城市id
@property (nonatomic, copy, readonly) NSString *uuid;       //设备号
@property (nonatomic, copy, readonly) NSString *model;            //设备名称
@property (nonatomic, copy, readonly) NSString *systemName;            //系统名称
@property (nonatomic, copy, readonly) NSString *systemVersion;            //系统版本
@property (nonatomic, copy, readonly) NSString *cfBundleVersion;           //Bundle版本
@property (nonatomic, copy, readonly) NSString *from;         //请求来源，值都是@"mobile"
@property (nonatomic, copy, readonly) NSString *ostype;      //操作系统类型
@property (nonatomic, copy, readonly) NSString *nowtime;        //发送请求的时间
@property (nonatomic, copy, readonly) NSString *macAddr;
@property (nonatomic, readonly) BOOL isReachable;

// log相关的参数
@property (nonatomic, copy) NSString *currentPageNumber;    //当前controller的pageNumber，记log用
@property (nonatomic, copy) NSString *uid; //登录用户token
@property (nonatomic, copy) NSString *chatid; //登录用户chat id
@property (nonatomic, copy) NSString *ccid; // 用户选择的城市id

@property (nonatomic, copy, readonly) NSString *geoCityid; // 用户当前所在城市的id
@property (nonatomic, copy, readonly) NSString *backPage;         //上一个页面的pageNumber,记log用
@property (nonatomic, copy, readonly) NSString *guid;
@property (nonatomic, copy, readonly) NSString *net;
@property (nonatomic, copy, readonly) NSString *ip;
@property (nonatomic, copy, readonly) NSString *geo;
@property (nonatomic, copy, readonly) NSString *ver; // log 版本
@property (nonatomic, copy, readonly) NSString *mac;
@property (nonatomic, copy, readonly) NSString *platform;
@property (nonatomic, copy, readonly) NSString *pmodel;

+ (instancetype)sharedInstance;
- (void)configWithChannelID:(NSString *)channelID appName:(NSString *)appName appType:(CCAppType)appType ccid:(NSString *)ccid;

@end
