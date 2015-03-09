//
//  CCModalTransitionAnimator.m
//  CCModalTransition
//
//  Created by 陈爱彬 on 15/3/9.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "CCModalTransitionAnimator.h"

@interface CCModalTransitionAnimator()
{
    UIView *_coverView;
    UIView *_snapView;
}
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property BOOL isDismiss;
@end

@implementation CCModalTransitionAnimator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _transitionDuration = 0.5;
        _canTapToDismiss = YES;
        _modalBackgroundColor = [UIColor blueColor];
    }
    return self;
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.transitionDuration;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (self.isDismiss) {
        CGRect finalRect = CGRectMake(0, CGRectGetHeight(toViewController.view.bounds), CGRectGetWidth(fromViewController.view.bounds), CGRectGetHeight(fromViewController.view.bounds));
        CGRect snapFinalRect = toViewController.view.frame;

        //Dismiss
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             //1
                             CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
                             _snapView.transform = transform;
                             _snapView.frame = CGRectMake((CGRectGetWidth(snapFinalRect) - CGRectGetWidth(_snapView.frame)) / 2, 0, CGRectGetWidth(_snapView.frame), CGRectGetHeight(_snapView.frame));
                             //2
                             _coverView.alpha = 0.f;
                             //3
                             fromViewController.view.frame = finalRect;
                         }completion:^(BOOL finished) {
                             //add view
                             [containerView addSubview:toViewController.view];
                             //remove
                             [_coverView removeFromSuperview];
                             [_snapView removeFromSuperview];
                             self.modalViewController = nil;
                             [transitionContext completeTransition:YES];
                         }];
    }else{
        //Present
        containerView.backgroundColor = _modalBackgroundColor;
        CGRect startRect = CGRectMake(0, CGRectGetHeight(fromViewController.view.bounds), CGRectGetWidth(toViewController.view.bounds), CGRectGetHeight(toViewController.view.bounds));
        CGRect toRect = CGRectMake(0, CGRectGetHeight(fromViewController.view.bounds) - CGRectGetHeight(toViewController.view.bounds), CGRectGetWidth(toViewController.view.bounds), CGRectGetHeight(toViewController.view.bounds));
        CGRect snapOriginRect = fromViewController.view.frame;
        //snapshot
        _snapView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];
        _snapView.frame = snapOriginRect;
        [containerView addSubview:_snapView];
        [containerView bringSubviewToFront:_snapView];
        [fromViewController.view removeFromSuperview];

        if (!_coverView) {
            _coverView = [[UIView alloc] initWithFrame:containerView.bounds];
            _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
//            _coverView.alpha = 0.f;
        }
        [containerView addSubview:_coverView];
        //gesture
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_coverView addGestureRecognizer:self.tapGesture];
        //add view
        toViewController.view.frame = startRect;
        [containerView addSubview:toViewController.view];

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             //1
                             CGAffineTransform transform = CGAffineTransformMakeScale(0.95, 0.95);
                             _snapView.transform = transform;
                             _snapView.frame = CGRectMake((CGRectGetWidth(snapOriginRect) - CGRectGetWidth(_snapView.frame)) / 2, 20, CGRectGetWidth(_snapView.frame), CGRectGetHeight(_snapView.frame));
                             //2
                             toViewController.view.frame = toRect;
                         }completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if (self.canTapToDismiss && self.modalViewController) {
        [self.modalViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - UIViewControllerTransitioningDelegate Methods
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isDismiss = NO;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isDismiss = YES;
    return self;
}
@end
