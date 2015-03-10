//
//  ViewController.m
//  CCModalTransition
//
//  Created by 陈爱彬 on 15/3/9.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "CCModalTransitionAnimator.h"

@interface ViewController ()

@property (nonatomic,strong) CCModalTransitionAnimator *animator;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 250, 120, 40);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"Tap me!" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}
- (void)buttonTapped
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    DetailViewController *detailVc = [[DetailViewController alloc] init];
    detailVc.view.frame = CGRectMake(0, 80, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 80);
    
    self.animator = [[CCModalTransitionAnimator alloc] initWithModalViewController:detailVc];
//    self.animator.modalViewController = detailVc;
    self.animator.dragable = YES;
    self.animator.canTapToDismiss = YES;
    self.animator.dismissBlock = ^(BOOL finished) {
        //drag to dismiss finished
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    };
    
    detailVc.transitioningDelegate = self.animator;
    [self presentViewController:detailVc animated:YES completion:nil];
}

@end
