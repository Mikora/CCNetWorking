//
//  CCAPIBaseManager.h
//  Pods
//
//  Created by 黄成 on 15/8/13.
//
//

#import <Foundation/Foundation.h>
#import "CCURLResponse.h"
@class CCAPIBaseManager;

// 在调用成功之后的params里面可以用这个字段取出requestid
static NSString * const kCCAPIBaseManagerRequestID = @"kCCAPIBaseManagerRequestID";

/*
    这个类适用于给外部访问api的基类，任何继承这个类的都要添加两个方法
        - (NSString*)methodName{
            return @"cc.searchMap";
        }
        - (CCServiceType)serviceType{
            return DemoServiceID;
        }
    外界适用manager的时候，如果需要调用api，只需要掉用loaddata即可，manager找paramsource来调用API的参数
    调用成功或者失败，都会调用delegate的回调函数
 
    继承的子类manager可以重载basemanager提供的方法来实现一些扩展
 */

/*
 CCAPIManagerApiCallbackDelegate
 */
@protocol CCAPIManagerApiCallbackDelegate <NSObject>

@required

- (void)managerCallApiDidSuccess:(CCAPIBaseManager*)manager;
- (void)managerCallApiDidFailed:(CCAPIBaseManager *)manager;

@end


/*
 CCAPIManagerCallbackDataReformer
 */

@protocol CCAPIManagerCallbackDataReformer <NSObject>

@required

- (id)manager:(CCAPIBaseManager*)manager reformData:(NSDictionary*)data;

@end


/*
 * 验证器，用于验证API的返回或者调用API的参数是否正确
 * CCAPIManagerValidator
 */
@protocol CCAPIManagerValidator <NSObject>

@required

- (BOOL)manager:(CCAPIBaseManager*)manager isCorrectWithCallbackData:(NSDictionary*)data;
- (BOOL)manager:(CCAPIBaseManager*)manager isCorrectWithParamsData:(NSDictionary*)data;

@end

/*
 * CCAPIManagerParamSourceDelegate
 * 让manager能够调用API所需的数据
 */

@protocol CCAPIManagerParamSourceDelegate <NSObject>

@required

- (NSDictionary*)paramsForApi:(CCAPIBaseManager*)manager;

@end


typedef NS_ENUM (NSUInteger, CCAPIManagerErrorType){
    CCAPIManagerErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    CCAPIManagerErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    CCAPIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    CCAPIManagerErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    CCAPIManagerErrorTypeTimeout,       //请求超时。RTApiProxy设置的是20秒超时，具体超时时间的设置请自己去看RTApiProxy的相关代码。
    CCAPIManagerErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

typedef NS_ENUM (NSUInteger, CCAPIManagerRequestType){
    CCAPIManagerRequestTypeGet = 1,
    CCAPIManagerRequestTypePost = 2,
    CCAPIManagerRequestTypeRestGet = 3,
    CCAPIManagerRequestTypeRestPost = 4
};

@protocol CCAPIManager <NSObject>

@required

- (NSString*)methodName;
- (NSString*)serviceType;
- (CCAPIManagerRequestType)requestType;

@optional

- (void)cleanData;
- (NSDictionary*)reformParams:(NSDictionary*)param;
- (BOOL)shouldCache;

@end

/*
 *
 *RTAPIBaseManager的派生类必须符合这些protocal
 */
@protocol CCAPIManagerInterceptor <NSObject>

@optional
- (void)manager:(CCAPIBaseManager *)manager beforePerformSuccessWithResponse:(CCURLResponse *)response;
- (void)manager:(CCAPIBaseManager *)manager afterPerformSuccessWithResponse:(CCURLResponse *)response;

- (void)manager:(CCAPIBaseManager *)manager beforePerformFailWithResponse:(CCURLResponse *)response;
- (void)manager:(CCAPIBaseManager *)manager afterPerformFailWithResponse:(CCURLResponse *)response;

- (BOOL)manager:(CCAPIBaseManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(CCAPIBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end

@interface CCAPIBaseManager : NSObject

@property (nonatomic,weak) id<CCAPIManagerApiCallbackDelegate> delegate;
@property (nonatomic,weak) id<CCAPIManagerParamSourceDelegate> paramSource;
@property (nonatomic,weak) id<CCAPIManagerValidator> validator;
@property (nonatomic,weak) id<CCAPIManagerInterceptor> interceptor;
@property (nonatomic,weak) NSObject<CCAPIManager> *child;
/*
 baseManager是不会去设置errorMessage的，派生的子类manager可能需要给controller提供错误信息。所以为了统一外部调用的入口，设置了这个变量。
 派生的子类需要通过extension来在保证errorMessage在对外只读的情况下使派生的manager子类对errorMessage具有写权限。
 */
@property (nonatomic,copy,readonly) NSString *errorMessage;
@property (nonatomic,readonly) CCAPIManagerErrorType errorType;

@property (nonatomic,assign,readonly) BOOL isReachable;
@property (nonatomic,assign,readonly) BOOL isLoading;

- (id)fetchDataWithReformer:(id<CCAPIManagerCallbackDataReformer>)reformer;
//使用loadData这个方法,这个方法会通过param source来获得参数，这使得参数的生成逻辑位于controller中的固定位置
- (NSInteger)loadData;

- (void)cancelAllRequests;
- (void)cancelRequestWithRequestID:(NSInteger)requestID;

//拦截器方法，继承后需要调用一下super
- (void)beforePerformSuccessWithResponse:(CCURLResponse *)response;
- (void)afterPerformSuccessWithResponse:(CCURLResponse *)response;

- (void)beforePerformFailWithResponse:(CCURLResponse *)response;
- (void)afterPerformFailWithResponse:(CCURLResponse *)response;

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params;
- (void)afterCallingAPIWithParams:(NSDictionary *)params;


/*
 用于给继承的类做重载，在调用API之前额外添加一些参数,但不应该在这个函数里面修改已有的参数。
 子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
 RTAPIBaseManager会先调用这个函数，然后才会调用到 id<RTAPIManagerValidator> 中的 manager:isCorrectWithParamsData:
 所以这里返回的参数字典还是会被后面的验证函数去验证的。
 
 假设同一个翻页Manager，ManagerA的paramSource提供page_size=15参数，ManagerB的paramSource提供page_size=2参数
 如果在这个函数里面将page_size改成10，那么最终调用API的时候，page_size就变成10了。然而外面却觉察不到这一点，因此这个函数要慎用。
 
 这个函数的适用场景：
 当两类数据走的是同一个API时，为了避免不必要的判断，我们将这一个API当作两个API来处理。
 那么在传递参数要求不同的返回时，可以在这里给返回参数指定类型。
 */
- (NSDictionary *)reformParams:(NSDictionary *)params;
- (void)cleanData;
- (BOOL)shouldCache;
@end
