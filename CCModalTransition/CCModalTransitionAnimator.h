//
//  CCModalTransitionAnimator.h
//  CCModalTransition
//
//  Created by 陈爱彬 on 15/3/9.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissFinishedBlock)(BOOL finished);

@interface CCModalTransitionAnimator : UIPercentDrivenInteractiveTransition
<UIViewControllerAnimatedTransitioning,
UIViewControllerTransitioningDelegate>

//used for dismiss modalViewController when tapGesture handled
@property (nonatomic,strong) UIViewController *modalViewController;
@property CGFloat transitionDuration;
//default 0.95
@property CGFloat behindViewScale;
@property BOOL canTapToDismiss;
@property (nonatomic,strong) UIColor *modalBackgroundColor;
//if set to yes,modalViewController need not to be nil
@property (nonatomic,assign,getter=isDragable) BOOL dragable;
//used for Interactive
@property (nonatomic,copy) DismissFinishedBlock dismissBlock;

- (instancetype)initWithModalViewController:(UIViewController *)modalViewController;

@end
