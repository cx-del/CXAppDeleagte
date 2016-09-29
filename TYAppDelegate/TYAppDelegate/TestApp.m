//
//  TestApp.m
//  TYAppDelegate
//
//  Created by DCX on 16/9/27.
//  Copyright © 2016年 戴晨惜. All rights reserved.
//

#import "TestApp.h"
#import <UIKit/UIKit.h> 
#import "TYModule.h"

@implementation TestApp

TY_RegisterAppDelegate_Load {
    
}

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    NSLog(@"%s  －－  －－ %@",__FUNCTION__,self);

    
    
    return YES;
}

@end
