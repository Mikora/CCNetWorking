//
//  CCApiLoggerConfig.m
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import "CCApiLoggerConfig.h"
#import "CCAppContext.h"

@implementation CCApiLoggerConfig

- (void)configWithAppType:(CCAppType)appType{
    switch (appType) {
        case CCAppTypeDemo:{
            self.channelID = [CCAppContext sharedInstance].channelID;
            self.appKey = @"appkey";
            self.logAppName = [CCAppContext sharedInstance].appName;
            self.serviceType = @"kServiceDemo";
            self.sendLogMethod = @"admin.writeApplog";
            self.sendActionMethod = @"admin.recordaction";
            self.sendLogKey = @"data";
            self.sendActionKey = @"action_note";
        }break;
            
        default:
            break;
    }
}


@end
