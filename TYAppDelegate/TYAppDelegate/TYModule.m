//
//  TYModule.m
//  TYAppDelegate
//
//  Created by DCX on 16/9/13.
//  Copyright © 2016年 戴晨惜. All rights reserved.
//

#import "TYModule.h"
#import <objc/runtime.h>
#import <objc/message.h>

typedef void (* _void_IMP)(id,...);
typedef BOOL (* _IMP)(id,...);

#define ADD_SELECTOR_PREFIX(__SELECTOR__) @selector(TY_##__SELECTOR__)

#define SWIZZLE_DELEGATE_METHOD(__SELECTORSTRING__) \
Swizzle([delegate class], @selector(__SELECTORSTRING__), class_getClassMethod([TYModule class], ADD_SELECTOR_PREFIX(__SELECTORSTRING__))); \

#define TY_APPDELEGATE_CALL_ORTHER(application,...) \
for (id obj in TYModuleObjects) { \
    if ([obj respondsToSelector:_cmd]) { \
        Method m1 = class_getInstanceMethod([obj class], _cmd); \
        IMP method1 = method_getImplementation(m1); \
        _void_IMP callMethod1 = (_void_IMP)method1; \
        callMethod1(obj,_cmd,application,##__VA_ARGS__); \
    } \
} \
for (Class cla in TYModuleClass) { \
    if ([cla respondsToSelector:_cmd]) { \
        Method m2 = class_getClassMethod([cla class], _cmd); \
        IMP method2 = method_getImplementation(m2); \
        _void_IMP callMethod2 = (_void_IMP)method2; \
        callMethod2(cla,_cmd,application,##__VA_ARGS__); \
    } \
} \

#define TY_APPDELEGATE_METHOD(application,...) \
SEL ty_selector = NSSelectorFromString([NSString stringWithFormat:@"TY_%@", NSStringFromSelector(_cmd)]); \
Method m = class_getClassMethod([TYModule class], ty_selector); \
IMP method = method_getImplementation(m); \
if (!sel_isEqual(ty_selector, _cmd)) { \
    _void_IMP callMethod = (_void_IMP)method; \
    callMethod(self,ty_selector,application, ##__VA_ARGS__); \
} \
TY_APPDELEGATE_CALL_ORTHER(application, ##__VA_ARGS__) \

#define TY_APPDELEGATE_METHOD_RETURN(application,...) \
BOOL returnValue = NO; \
SEL ty_selector = NSSelectorFromString([NSString stringWithFormat:@"TY_%@", NSStringFromSelector(_cmd)]); \
Method m = class_getClassMethod([TYModule class], ty_selector); \
IMP method = method_getImplementation(m); \
if (!sel_isEqual(ty_selector, _cmd)) { \
    _IMP callMethod = (_IMP)method; \
    returnValue = callMethod(self,ty_selector,application, ##__VA_ARGS__); \
} \
TY_APPDELEGATE_CALL_ORTHER(application, ##__VA_ARGS__) \
return returnValue; \

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

void Swizzle(Class class, SEL originalSelector, Method swizzledMethod)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    SEL swizzledSelector = method_getName(swizzledMethod);

    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod && originalMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


static NSMutableSet<id> * TYModuleObjects;
static NSMutableSet<Class> * TYModuleClass;

@implementation UIApplication (DCX)

- (void)TY_setDelegate:(id <UIApplicationDelegate>)delegate {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SWIZZLE_DELEGATE_METHOD(applicationDidFinishLaunching:);
        SWIZZLE_DELEGATE_METHOD(application: willFinishLaunchingWithOptions:);
        SWIZZLE_DELEGATE_METHOD(application: didFinishLaunchingWithOptions:);
        SWIZZLE_DELEGATE_METHOD(applicationDidBecomeActive:)
        SWIZZLE_DELEGATE_METHOD(applicationWillResignActive:)
        SWIZZLE_DELEGATE_METHOD(application: handleOpenURL:)
        SWIZZLE_DELEGATE_METHOD(application: openURL:sourceApplication:annotation:)
        SWIZZLE_DELEGATE_METHOD(application: openURL: options:)
        SWIZZLE_DELEGATE_METHOD(applicationDidReceiveMemoryWarning:)
        SWIZZLE_DELEGATE_METHOD(applicationWillTerminate:)
        SWIZZLE_DELEGATE_METHOD(applicationSignificantTimeChange:);
        SWIZZLE_DELEGATE_METHOD(application: didRegisterForRemoteNotificationsWithDeviceToken:)
        SWIZZLE_DELEGATE_METHOD(application: didFailToRegisterForRemoteNotificationsWithError:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveRemoteNotification:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveRemoteNotification: fetchCompletionHandler:)
        SWIZZLE_DELEGATE_METHOD(application: handleEventsForBackgroundURLSession: completionHandler:)
        SWIZZLE_DELEGATE_METHOD(application: handleWatchKitExtensionRequest: reply:)
        SWIZZLE_DELEGATE_METHOD(applicationShouldRequestHealthAuthorization:)
        SWIZZLE_DELEGATE_METHOD(applicationDidEnterBackground:)
        SWIZZLE_DELEGATE_METHOD(applicationWillEnterForeground:)
        SWIZZLE_DELEGATE_METHOD(applicationProtectedDataWillBecomeUnavailable:)
        SWIZZLE_DELEGATE_METHOD(applicationProtectedDataDidBecomeAvailable:)
    });
    [self TY_setDelegate:delegate];
}

@end

@implementation TYModule

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([UIApplication class], @selector(setDelegate:), class_getInstanceMethod([UIApplication class], @selector(TY_setDelegate:)));
    });
}

+ (void)registerAppDelegateObject:(nonnull id) obj {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TYModuleObjects = [NSMutableSet new];
    });
    [TYModuleObjects addObject:obj];
}
+ (void)registerAppDelegateClass:(nonnull Class)cla {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TYModuleClass = [NSMutableSet new];
    });
    [TYModuleClass addObject:cla];
}

+ (void)TY_applicationDidFinishLaunching:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (void)TY_applicationDidEnterBackground:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (void)TY_applicationWillEnterForeground:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

#if UIKIT_STRING_ENUMS
+ (BOOL)TY_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    TY_APPDELEGATE_METHOD_RETURN(application,launchOptions)
}

+ (BOOL)TY_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions  {
    TY_APPDELEGATE_METHOD_RETURN(application,launchOptions)
}

#else
+ (BOOL)TY_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    TY_APPDELEGATE_METHOD_RETURN(application,launchOptions)
}

+ (BOOL)TY_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    TY_APPDELEGATE_METHOD_RETURN(application,launchOptions)
}
#endif

+ (void)TY_applicationDidBecomeActive:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (void)TY_applicationWillResignActive:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (BOOL)TY_application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    TY_APPDELEGATE_METHOD_RETURN(application,url)
}

+ (BOOL)TY_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation  {
    TY_APPDELEGATE_METHOD_RETURN(application,url,sourceApplication,annotation)
}

+ (BOOL)TY_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    TY_APPDELEGATE_METHOD_RETURN(app,url,options)
}

+ (void)TY_applicationDidReceiveMemoryWarning:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (void)TY_applicationWillTerminate:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (void)TY_applicationSignificantTimeChange:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (void)TY_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    TY_APPDELEGATE_METHOD(application,deviceToken)
}

+ (void)TY_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    TY_APPDELEGATE_METHOD(application,error)
}

+ (void)TY_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    TY_APPDELEGATE_METHOD(application,userInfo)
}

+ (void)TY_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    TY_APPDELEGATE_METHOD(application,userInfo,completionHandler)
}

+ (void)TY_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    TY_APPDELEGATE_METHOD(application,identifier,completionHandler)
}

+ (void)TY_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply {
    TY_APPDELEGATE_METHOD(application,userInfo,reply)
}

+ (void)TY_applicationShouldRequestHealthAuthorization:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (void)TY_applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

+ (void)TY_applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
    TY_APPDELEGATE_METHOD(application)
}

@end


