//
//  UIDevice+IdentifierAddition.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "UIDevice+IdentifierAddition.h"
#import "NSString+CCNetworkingMethod.h"
#import "CCUDID.h"
#include <sys/utsname.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface UIDevice(Private)


- (NSString *) localMAC;

@end

@implementation UIDevice (IdentifierAddition)


#pragma mark - Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *) localMAC{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}


#pragma mark - Public Methods

- (NSString *)createUUID{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge NSString *)string;
}

- (NSString *)uuid{
    NSString *key = @"CCUUID";
    NSString *uuid = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    if (uuid.length == 0) {
        [[NSUserDefaults standardUserDefaults]setObject:[self createUUID] forKey:key];
        return [[NSUserDefaults standardUserDefaults]objectForKey:key];
    }else{
        return uuid;
    }
}

- (NSString *)udid{
    NSString *udid = [[CCUDID sharedInstance] UDID];
    return udid;
}

- (NSString *)macaddress{
    
    NSString *key = @"CCMACAddressMD5";
    NSString *macAddress = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    if (macAddress.length == 0) {
        macAddress = [self localMAC];
        if (macAddress.length>0){
            [[NSUserDefaults standardUserDefaults] setObject:macAddress forKey:key];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"macaddressMD5"];
        }
    }
    return macAddress;
}

- (NSString *)macaddressMD5{
    NSString *key = @"MACAddressMD5";
    NSString *macid = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (macid.length == 0) {
        NSString *macaddress = [[UIDevice currentDevice] macaddress];
        macid = [macaddress CC_md5];
        if (!macid){
            macid = @"macaddress_empty";
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:macid forKey:key];
        }
    }
    return macid;
}

- (NSString *)machineType{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machineTypeString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([machineTypeString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([machineTypeString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([machineTypeString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([machineTypeString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([machineTypeString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([machineTypeString isEqualToString:@"iPhone5,1"])    return @"iPhone 5(AT&T)";
    if ([machineTypeString isEqualToString:@"iPhone5,2"])    return @"iPhone 5(GSM/CDMA)";
    if ([machineTypeString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    //iPod Touch
    if ([machineTypeString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([machineTypeString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([machineTypeString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([machineTypeString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([machineTypeString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    //iPad
    if ([machineTypeString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([machineTypeString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([machineTypeString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([machineTypeString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([machineTypeString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([machineTypeString isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([machineTypeString isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    if ([machineTypeString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([machineTypeString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM)";
    if ([machineTypeString isEqualToString:@"iPad3,3"])      return @"iPad 3 (CDMA)";
    if ([machineTypeString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([machineTypeString isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([machineTypeString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    //Simulator
    if ([machineTypeString isEqualToString:@"i386"])         return @"Simulator";
    if ([machineTypeString isEqualToString:@"x86_64"])       return @"Simulator";
    return machineTypeString;

}

- (NSString *)ostype{
    UIDevice *device = [UIDevice currentDevice];
    NSString *os = [device systemVersion];
    NSArray *array = [os componentsSeparatedByString:@"."];
    NSString *ostype = @"iOS";
    if (array.count > 0) {
        ostype = [NSString stringWithFormat:@"%@%@",ostype,[array objectAtIndex:0]];
    }
    return ostype;
}

@end
