//
//  TYModule.m
//  TYAppDelegate
//
//  Created by DCX on 16/9/13.
//  Copyright © 2016年 戴晨惜. All rights reserved.
//

#import "TYModule.h"
#import <stdarg.h>
#import <objc/runtime.h>
#import <objc/message.h>

#define ADD_SELECTOR_PREFIX(__SELECTOR__) @selector(TY_##__SELECTOR__)

#define SWIZZLE_DELEGATE_METHOD(__SELECTORSTRING__) \
Swizzle([delegate class], @selector(__SELECTORSTRING__), class_getClassMethod([TYModule class], ADD_SELECTOR_PREFIX(__SELECTORSTRING__))); \

#define TY_APPDELEGATE_CALL_ORTHER( _cmd_, _application_, _args1_, _args2_, _args3_) \
for (id obj in TYModuleObjects) { \
    if ([obj respondsToSelector:_cmd_]) { \
        ((void (*)(id, SEL, id , id , id , id))(void *)objc_msgSend)(obj,_cmd_,_application_,_args1_,_args2_,_args3_); \
    } \
} \
for (Class cla in TYModuleClass) { \
    if ([cla respondsToSelector:_cmd_]) { \
        ((void (*)(id, SEL, id , id , id , id))(void *)objc_msgSend)(cla,_cmd_,_application_,_args1_,_args2_,_args3_); \
    } \
} \

static NSMutableSet<id> * TYModuleObjects;
static NSMutableSet<Class> * TYModuleClass;

BOOL TY_Appdelegate_method_return(id _self_, SEL _cmd_, id _application_, id _args1_, id _args2_, id _args3_) {
    BOOL returnValue = NO;
    SEL ty_selector = NSSelectorFromString([NSString stringWithFormat:@"TY_%@", NSStringFromSelector(_cmd_)]);
    Method m = class_getClassMethod([TYModule class], ty_selector);
    IMP method = method_getImplementation(m);
    if (![NSStringFromSelector(_cmd_) hasPrefix:@"TY_"]) {
        BOOL (* callMethod)(id,SEL,id,id,id,id) = (void *)method;
        returnValue = callMethod(_self_,ty_selector,_application_,_args1_,_args2_,_args3_);
    }
    TY_APPDELEGATE_CALL_ORTHER(_cmd_, _application_, _args1_, _args2_, _args3_)
    return returnValue;
}

void TY_Appdelegate_method(id _self_, SEL _cmd_, id _application_, id _args1_, id _args2_) {
    SEL ty_selector = NSSelectorFromString([NSString stringWithFormat:@"TY_%@", NSStringFromSelector(_cmd_)]);
    Method m = class_getClassMethod([TYModule class], ty_selector);
    IMP method = method_getImplementation(m);
    if (![NSStringFromSelector(_cmd_) hasPrefix:@"TY_"]) {
        void (* callMethod)(id,SEL,id,id,id) = (void *)method;
        callMethod(_self_,ty_selector,_application_,_args1_,_args2_);
    }
    TY_APPDELEGATE_CALL_ORTHER(_cmd_, _application_, _args1_, _args2_, nil)
}

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
        SWIZZLE_DELEGATE_METHOD(application: openURL:  sourceApplication: annotation:)
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
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)TY_applicationDidEnterBackground:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)TY_applicationWillEnterForeground:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

#if UIKIT_STRING_ENUMS
+ (BOOL)TY_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    return TY_Appdelegate_method_return(self,_cmd,application, launchOptions,nil,nil);
}

+ (BOOL)TY_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions  {
    return TY_Appdelegate_method_return(self,_cmd,application, launchOptions,nil,nil);
}

#else

+ (BOOL)TY_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    return TY_Appdelegate_method_return(self,_cmd,application, launchOptions,nil,nil);
}

+ (BOOL)TY_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    return TY_Appdelegate_method_return(self,_cmd,application, launchOptions,nil,nil);
}
#endif

+ (void)TY_applicationDidBecomeActive:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)TY_applicationWillResignActive:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (BOOL)TY_application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return TY_Appdelegate_method_return(self,_cmd,application,url,nil,nil);
}

+ (BOOL)TY_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation  {
    return TY_Appdelegate_method_return(self,_cmd,application,url,sourceApplication,annotation);
}

+ (BOOL)TY_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return TY_Appdelegate_method_return(self,_cmd,application,url,options,nil);
}

+ (void)TY_applicationDidReceiveMemoryWarning:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)TY_applicationWillTerminate:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)TY_applicationSignificantTimeChange:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)TY_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    TY_Appdelegate_method(self, _cmd, application, deviceToken, nil);
}

+ (void)TY_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    TY_Appdelegate_method(self, _cmd, application, error, nil);
}

+ (void)TY_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    TY_Appdelegate_method(self, _cmd, application, userInfo, nil);
}

+ (void)TY_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    TY_Appdelegate_method(self, _cmd, application, userInfo, completionHandler);
}

+ (void)TY_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    TY_Appdelegate_method(self, _cmd, application, identifier, completionHandler);
}

+ (void)TY_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply {
    TY_Appdelegate_method(self, _cmd, application, userInfo, reply);
}

+ (void)TY_applicationShouldRequestHealthAuthorization:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)TY_applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)TY_applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
    TY_Appdelegate_method(self, _cmd, application, nil, nil);
}

@end


