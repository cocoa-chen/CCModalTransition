//
//  DetailViewController.m
//  CCModalTransition
//
//  Created by 陈爱彬 on 15/3/9.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor purpleColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 250, 120, 40);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"close" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}

- (void)closeButtonTapped
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
