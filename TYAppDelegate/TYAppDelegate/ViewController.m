//
//  ViewController.m
//  TYAppDelegate
//
//  Created by DCX on 16/9/13.
//  Copyright © 2016年 戴晨惜. All rights reserved.
//

#import "ViewController.h"
#import "TYModule.h"

@interface ViewController ()

@end

@implementation ViewController



TY_RegisterAppDelegate_Load {

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [TYModule registerAppDelegateObject:self];
//    [TYModule registerAppDelegateClass:[self class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismiss:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"%s  －－  －－ %@",__FUNCTION__,self);
    
    return YES;
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {

    NSLog(@"%s  －－  －－ %@",__FUNCTION__,self);
    
    
    NSLog(@"s  －－  －－ __FUNCTION__,");
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSLog(@"%s  －－  －－ %@",__FUNCTION__,self);
    
    
    NSLog(@"s  －－  －－ __FUNCTION__,");
    
}

@end
