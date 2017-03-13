//
//  ZYSuspensionView.m
//  ZYSuspensionView
//
//  Created by ripper on 16-02-25.
//  Copyright (c) 2016年 ripper. All rights reserved.
//

#import "ZYSuspensionView.h"
#import "NSObject+ZYSuspensionView.h"
#import "ZYSuspensionManager.h"

@interface ZYSuspensionViewController : UIViewController

@end

@implementation ZYSuspensionViewController

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end

@implementation ZYSuspensionView

+ (instancetype)defaultSuspensionViewWithDelegate:(id<ZYSuspensionViewDelegate>)delegate
{
    ZYSuspensionView *sus = [[ZYSuspensionView alloc] initWithFrame:CGRectMake(- 50.0 / 6, 100, 50, 50)
                                                              color:[UIColor colorWithRed:0.21f green:0.45f blue:0.88f alpha:1.00f]
                                                           delegate:delegate];
    return sus;
}

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<ZYSuspensionViewDelegate>)delegate
{
    if(self = [super initWithFrame:frame])
    {
        self.delegate = delegate;
        self.userInteractionEnabled = YES;
        self.backgroundColor = color;
        self.alpha = .7;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(changeLocation:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - event response
- (void)changeLocation:(UIPanGestureRecognizer*)p
{
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [p locationInView:appWindow];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1;
    }else if(p.state == UIGestureRecognizerStateChanged) {
        [ZYSuspensionManager windowForKey:self.md5Key].center = CGPointMake(panPoint.x, panPoint.y);
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        self.alpha = .7;
        
        CGFloat touchWidth = self.frame.size.width;
        CGFloat touchHeight = self.frame.size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;

        CGFloat left = fabs(panPoint.x);
        CGFloat right = fabs(screenWidth - left);
        CGFloat top = fabs(panPoint.y);
        CGFloat bottom = fabs(screenHeight - top);
        
        CGFloat minSpace = 0;
        if (self.leanType == ZYSuspensionViewLeanTypeHorizontal) {
            minSpace = MIN(left, right);
        }else{
            minSpace = MIN(MIN(MIN(top, left), bottom), right);
        }
        CGPoint newCenter;
        CGFloat targetY = 0;
        
        //校正Y
        if (panPoint.y < 15 + touchHeight / 2.0) {
            targetY = 15 + touchHeight / 2.0;
        }else if (panPoint.y > (screenHeight - touchHeight / 2.0 - 15)) {
            targetY = screenHeight - touchHeight / 2.0 - 15;
        }else{
            targetY = panPoint.y;
        }
        
        if (minSpace == left) {
            newCenter = CGPointMake(touchHeight / 3, targetY);
        }else if (minSpace == right) {
            newCenter = CGPointMake(screenWidth - touchHeight / 3, targetY);
        }else if (minSpace == top) {
            newCenter = CGPointMake(panPoint.x, touchWidth / 3);
        }else if (minSpace == bottom) {
            newCenter = CGPointMake(panPoint.x, screenHeight - touchWidth / 3);
        }
        
        [UIView animateWithDuration:.25 animations:^{
            [ZYSuspensionManager windowForKey:self.md5Key].center = newCenter;
        }];
    }else{
        NSLog(@"pan state : %zd", p.state);
    }
}

- (void)click
{
    if([self.delegate respondsToSelector:@selector(suspensionViewClick:)])
    {
        [self.delegate suspensionViewClick:self];
    }
}

#pragma mark - public methods
- (void)show
{
    UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    UIWindow *backWindow = [[UIWindow alloc] initWithFrame:self.frame];
    backWindow.windowLevel = UIWindowLevelAlert * 2;
    backWindow.rootViewController = [[ZYSuspensionViewController alloc] init];
    [backWindow makeKeyAndVisible];
    [ZYSuspensionManager saveWindow:backWindow forKey:self.md5Key];

    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.layer.cornerRadius = self.frame.size.width / 2.0;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.0;
    self.clipsToBounds = YES;
    [backWindow addSubview:self];
    
    // 保持原先的keyWindow，避免一些不必要的问题
    [currentKeyWindow makeKeyWindow];
}

- (void)removeFromScreen
{
    [ZYSuspensionManager destroyWindowForKey:self.md5Key];
}

@end
