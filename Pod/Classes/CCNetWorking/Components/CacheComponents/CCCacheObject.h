//
//  CCCacheObject.h
//  Pods
//
//  Created by 黄成 on 15/8/13.
//
//

#import <Foundation/Foundation.h>

@interface CCCacheObject : NSObject

@property (nonatomic,copy,readonly) NSData *content;
@property (nonatomic,copy,readonly) NSDate *lastUpdateTime;

@property (nonatomic,assign,readonly) BOOL isOutdated;
@property (nonatomic,assign,readonly) BOOL isEmpty;

- (instancetype)initWithContent:(NSData*)content;
- (void)updateContent:(NSData*)content;

@end
