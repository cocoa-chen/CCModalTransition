//
//  CCModalTransitionAnimator.h
//  CCModalTransition
//
//  Created by 陈爱彬 on 15/3/9.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCModalTransitionAnimator : NSObject
<UIViewControllerAnimatedTransitioning,
UIViewControllerTransitioningDelegate>

//used for dismiss modalViewController when tapGesture handled
@property (nonatomic,strong) UIViewController *modalViewController;
@property CGFloat transitionDuration;
@property BOOL canTapToDismiss;
@property (nonatomic,strong) UIColor *modalBackgroundColor;

@end
