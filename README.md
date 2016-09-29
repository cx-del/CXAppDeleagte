# CXAppDeleagte
无代码入侵，获取AppDelegate声明周期


```
/** 
 
 需要收到 AppDelegate 的类或者对象直接调用注册方法
 
 或者使用 宏 TY_RegisterAppDelegate_Load 重写load方法注册  注意 此宏后面需要加 “ { } ” 
 
 注册完成之后 在实现文件内声明 AppDelegate 同名方法，就会同步调用
 
 */

#import <UIKit/UIKit.h>

#define TY_RegisterAppDelegate_Load \
+ (void)load { \
    [TYModule registerAppDelegateClass:[self class]]; \
    if ([self respondsToSelector:@selector(TY_load)]) { \
        [self performSelector:@selector(TY_load)]; \
    } \
} \
+ (void)TY_load \

@interface TYModule : NSObject

/** 根据class注册 appdelegate 的方法调用 推荐用这个 */
+ (void)registerAppDelegateClass:(nonnull Class)cla;

/** 根据对象注册 appdelegate 的方法调用 注册后会持有该对象，酌情使用<单例的话就无所谓了> */
+ (void)registerAppDelegateObject:(nonnull id)obj;

@end
```



前置忘了改了
