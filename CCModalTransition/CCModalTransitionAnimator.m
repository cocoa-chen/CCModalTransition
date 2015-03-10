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
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong) id<UIViewControllerContextTransitioning>transitionContext;
@property CGFloat panStartLocation;
@property CGFloat tempOriginY;
@property BOOL isDismiss;
@property BOOL isInteractive;
@end

@implementation CCModalTransitionAnimator

- (instancetype)initWithModalViewController:(UIViewController *)modalViewController
{
    self = [self init];
    if (self) {
        _modalViewController = modalViewController;
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _transitionDuration = 0.5;
        _behindViewScale = 0.95;
        _canTapToDismiss = NO;
        _dragable = NO;
        _modalBackgroundColor = [UIColor blueColor];
    }
    return self;
}
- (void)setDragable:(BOOL)dragable
{
    _dragable = dragable;
    if (!self.modalViewController) {
        NSLog(@"modalViewController is nil,set dragable failed");
    }else{
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.modalViewController.view addGestureRecognizer:self.panGesture];
    }
}
#pragma mark - UIViewControllerAnimatedTransitioning Methods
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.transitionDuration;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isInteractive) {
        return;
    }
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
                             CGAffineTransform transform = CGAffineTransformMakeScale(_behindViewScale, _behindViewScale);
                             _snapView.transform = transform;
                             _snapView.frame = CGRectMake((CGRectGetWidth(snapOriginRect) - CGRectGetWidth(_snapView.frame)) / 2, 20, CGRectGetWidth(_snapView.frame), CGRectGetHeight(_snapView.frame));
                             //2
                             toViewController.view.frame = toRect;
                         }completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
}
- (void)animationEnded:(BOOL)transitionCompleted
{
    self.isInteractive = NO;
    self.transitionContext = nil;
}
#pragma mark - GestureHandler
- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if (self.canTapToDismiss && self.modalViewController) {
        [self.modalViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.modalViewController.view.window];
    location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(gesture.view.transform));
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.isInteractive = YES;
            self.panStartLocation = location.y;
            [self.modalViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
//            NSLog(@"locationY:%@",@(location.y));
//            NSLog(@"startY:%@",@(self.panStartLocation));
            CGFloat progress = (location.y - self.panStartLocation) / CGRectGetHeight(self.modalViewController.view.bounds);
//            NSLog(@"progress:%@",@(progress));
            progress = MIN(1.0, MAX(0.0, progress));
            [self updateInteractiveTransition:progress];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if ([gesture velocityInView:self.modalViewController.view].y > 0) {
                [self finishInteractiveTransition];
            }else{
                [self cancelInteractiveTransition];
            }
            self.isInteractive = NO;
        }
            break;
        default:
        {
            [self cancelInteractiveTransition];
            self.isInteractive = NO;
        }
            break;
    }
}
#pragma mark - UIViewControllerInteractiveTransitioning
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    UIViewController *fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.tempOriginY = fromViewController.view.frame.origin.y;
}
- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    UIViewController *fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //1
    CGFloat coverAlpha = 1 - percentComplete;
    _coverView.alpha = coverAlpha;
    //2
    CGRect updateRect = fromViewController.view.bounds;
    updateRect.origin.y = self.tempOriginY + CGRectGetHeight(updateRect) * percentComplete;
    fromViewController.view.frame = updateRect;
    //3
    CGFloat scaleFactor = (1 - _behindViewScale) * percentComplete + _behindViewScale;
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    _snapView.transform = transform;
    //4
    CGFloat snapOriginY = 20 * (1 - percentComplete);
    _snapView.frame = CGRectMake((CGRectGetWidth(toViewController.view.bounds) - CGRectGetWidth(_snapView.frame)) / 2, snapOriginY, CGRectGetWidth(_snapView.frame), CGRectGetHeight(_snapView.frame));
}
- (void)finishInteractiveTransition
{
    UIView *containerView = [self.transitionContext containerView];
    UIViewController *fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect finalRect = CGRectMake(0, CGRectGetHeight(toViewController.view.bounds), CGRectGetWidth(fromViewController.view.bounds), CGRectGetHeight(fromViewController.view.bounds));
    CGRect snapFinalRect = toViewController.view.frame;

    [UIView animateWithDuration:[self transitionDuration:self.transitionContext]
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
                         [self.transitionContext completeTransition:YES];
                         //block
                         if (self.dismissBlock) {
                             self.dismissBlock(finished);
                         }
                     }];
}
- (void)cancelInteractiveTransition
{
    UIViewController *fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect toRect = CGRectMake(0, CGRectGetHeight(toViewController.view.bounds) - CGRectGetHeight(fromViewController.view.bounds), CGRectGetWidth(fromViewController.view.bounds), CGRectGetHeight(fromViewController.view.bounds));
    CGRect snapOriginRect = toViewController.view.frame;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext]
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //1
                         CGAffineTransform transform = CGAffineTransformMakeScale(_behindViewScale, _behindViewScale);
                         _snapView.transform = transform;
                         _snapView.frame = CGRectMake((CGRectGetWidth(snapOriginRect) - CGRectGetWidth(_snapView.frame)) / 2, 20, CGRectGetWidth(_snapView.frame), CGRectGetHeight(_snapView.frame));
                         //2
                         fromViewController.view.frame = toRect;
                     }completion:^(BOOL finished) {
                         [self.transitionContext completeTransition:NO];
                     }];
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
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    if (self.isInteractive && self.dragable) {
        self.isDismiss = YES;
        return self;
    }
    return nil;
}

@end
