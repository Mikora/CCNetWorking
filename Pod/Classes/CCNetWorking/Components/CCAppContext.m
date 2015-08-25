//
//  CCAppContext.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "CCAppContext.h"
#import "AFNetworkReachabilityManager.h"
#import "CCApiLogger.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "UIDevice+IdentifierAddition.h"
#import "NSObject+CCNetworkingMethod.h"

@interface CCAppContext ()

@property (nonatomic, strong) UIDevice *device;
@property (nonatomic, copy, readwrite) NSString *uuid;
@property (nonatomic, copy, readwrite) NSString *model;
@property (nonatomic, copy, readwrite) NSString *guid;
@property (nonatomic, copy, readwrite) NSString *net;
@property (nonatomic, copy, readwrite) NSString *ip;
@property (nonatomic, copy, readwrite) NSString *systemName;
@property (nonatomic, copy, readwrite) NSString *systemVersion;
@property (nonatomic, copy, readwrite) NSString *cfBundleVersion;
@property (nonatomic, copy, readwrite) NSString *macAddr;
@property (nonatomic, copy, readwrite) NSString *from;
@property (nonatomic, copy, readwrite) NSString *ostype;
@property (nonatomic, copy, readwrite) NSString *backPage;
@property (nonatomic, copy, readwrite) NSString *platform;
@property (nonatomic, copy, readwrite) NSString *pmodel;

@end

@implementation CCAppContext

#pragma mark - getters and setters
- (UIDevice *)device
{
    if (_device == nil) {
        _device = [UIDevice currentDevice];
    }
    return _device;
}

- (NSString *)model
{
    if (_model == nil) {
        _model = [[self.device.model stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] CC_defaultValue:@""];
    }
    return _model;
}

- (NSString *)systemName
{
    if (_systemName == nil) {
        _systemName = [[self.device.systemName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] CC_defaultValue:@""];
    }
    return _systemName;
}
- (NSString *)systemVersion
{
    if (_systemVersion == nil) {
        _systemVersion = [self.device systemVersion];
    }
    return _systemVersion;
}

- (NSString *)cfBundleVersion
{
    if (_cfBundleVersion == nil) {
        _cfBundleVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] CC_defaultValue:@""];
    }
    return _cfBundleVersion;
}

- (NSString *)macAddr
{
    if (_macAddr == nil) {
        _macAddr = [[self.device macaddressMD5] CC_defaultValue:@""];
    }
    return _macAddr;
}

- (NSString *)uuid
{
    if (_uuid == nil) {
        _uuid = [[self.device uuid] CC_defaultValue:@""];
    }
    return _uuid;
}

- (NSString *)from
{
    if (_from == nil) {
        _from = @"mobile";
    }
    return _from;
}

- (NSString *)ostype
{
    if (_ostype == nil) {
        _ostype = [self.device.ostype CC_defaultValue:@""];
    }
    return _ostype;
}

- (NSString *)nowtime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NSLocalizedString(@"yyyyMMddHHmmss", nil)];
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)cityid
{
//    return [[AIFLocationManager sharedInstance] currentCityId];
    return @"";
}

- (void)setCurrentPageNumber:(NSString *)currentPageNumber
{
    self.backPage = _currentPageNumber;
    _currentPageNumber = [currentPageNumber copy];
}

- (NSString *)backPage
{
    if (_backPage == nil) {
        _backPage = @"-1";
    }
    return _backPage;
}

- (NSString *)channelID
{
    if (_channelID == nil) {
        _channelID = @"appstore";//默认channel id
    }
    return _channelID;
}

- (NSString *)appName
{
    if (_appName == nil) {
        _appName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    }
    return _appName;
}

- (NSString *)guid
{
    if (_guid == nil) {
        NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"CCGuid.string"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            _guid = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] copy];
        }
        else {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
            
            _guid = [[NSString alloc] initWithFormat:@"%@",uuidStr];
            
            CFRelease(uuidStr);
            CFRelease(uuid);
            
            [_guid writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
    return _guid;
}

- (NSString *)net
{
    if (_net == nil) {
        _net = @"";
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
            _net = @"2G3G";
        }
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
            _net = @"WiFi";
        }
    }
    return _net;
}

- (NSString *)ver
{
    return @"1.0";
}

- (NSString *)ip
{
    if (_ip == nil) {
        _ip = @"Error";
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;
        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces);
        if (success == 0) {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while(temp_addr != NULL) {
                if(temp_addr->ifa_addr->sa_family == AF_INET) {
                    // Check if interface is en0 which is the wifi connection on the iPhone
                    if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                        // Get NSString from C String
                        _ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    }
                }
                temp_addr = temp_addr->ifa_next;
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return _ip;
}

- (NSString *)geo
{
//    CLLocationCoordinate2D coordinate = [[AIFLocationManager sharedInstance].locatedCityLocation coordinate];
//    return [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
    //地理位置
    return @"";
}

- (NSString *)geoCityid
{
//    return [AIFLocationManager sharedInstance].locatedCityId;
    //所在城市
    return @"";
}

- (NSString *)platform
{
    if (_platform == nil) {
        _platform = @"ios";
    }
    return _platform;
}

- (NSString *)pmodel
{
    if (_pmodel == nil) {
        _pmodel = [[UIDevice currentDevice] machineType];
    }
    return _pmodel;
}

- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static CCAppContext *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCAppContext alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
//        [AIFLocationManager sharedInstance];
    });
    return sharedInstance;
}

- (void)configWithChannelID:(NSString *)channelID appName:(NSString *)appName appType:(CCAppType)appType ccid:(NSString *)ccid
{
    self.channelID = channelID;
    self.appName = appName;
    self.appType = appType;
    self.ccid = ccid;
    [[CCApiLogger sharedInstance].configParams configWithAppType:appType];
}

#pragma mark - overrided methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentPageNumber = @"-1";
    }
    return self;
}

@end
