//
//  testViewController.m
//  TYAppDelegate
//
//  Created by DCX on 16/9/28.
//  Copyright © 2016年 戴晨惜. All rights reserved.
//

#import "testViewController.h"
#import "ViewController.h"
#import "TYModule.h"
@interface testViewController ()

@property (nonatomic,strong) ViewController * c;

@end

@implementation testViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [TYModule registerAppDelegateClass:[ViewController class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)aaa:(id)sender {
    
    _c = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];//[[ViewController alloc] init];
    [self presentViewController:_c animated:YES completion:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_c) {
        _c = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
