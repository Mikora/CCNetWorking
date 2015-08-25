//
//  CCURLResponse.h
//  Pods
//
//  Created by 黄成 on 15/8/11.
//
//

#import <Foundation/Foundation.h>
#import "CCNetWorkingConfig.h"

@interface CCURLResponse : NSObject

@property (nonatomic,assign,readonly)   CCURLResponseStatus status;

@property (nonatomic,copy,readonly)     NSString            *contentString;
@property (nonatomic,copy,readonly)     id                  content;
@property (nonatomic,assign,readonly)   NSInteger           requestID;
@property (nonatomic,copy,readonly)     NSURLRequest        *request;
@property (nonatomic,copy,readonly)     NSData              *responseData;
@property (nonatomic,copy)              NSDictionary        *requestParams;
@property (nonatomic,assign,readonly)   BOOL                isCache;


- (instancetype)initWithResponseString:(NSString*)responseString requestID:(NSNumber*)requestID request:(NSURLRequest*)request responseData:(NSData*)responseData status:(CCURLResponseStatus)status;

- (instancetype)initWithResponseString:(NSString *)responseString requestID:(NSNumber *)requestID request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError*)error;

//这个的isCache＝YES,上面为NO
- (instancetype)initWithData:(NSData*)data;
@end
