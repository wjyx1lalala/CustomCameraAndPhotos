//
//  TopViewAlert.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/14.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "TopViewAlert.h"

#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define MAX_W (SCREEN_W > SCREEN_H ? SCREEN_W : SCREEN_H)
#define MIN_W (SCREEN_W > SCREEN_H ? SCREEN_H : SCREEN_W)
#define DEFAOULT_HEIGHT 84
#define ANIMTED_DELAY 2 //动画的延迟时间

@interface TopViewAlert ()

@property (nonatomic,strong)UILabel * label;
@property (nonatomic,assign)BOOL isShow;

@end

@implementation TopViewAlert

static TopViewAlert * shareinstance = nil;
+ (instancetype)shareAlert
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareinstance = [[self alloc] initWithFrame:CGRectMake(0, -DEFAOULT_HEIGHT, SCREEN_W, DEFAOULT_HEIGHT)];
    });
    return shareinstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareinstance = [super allocWithZone:zone];
    });
    return shareinstance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI{
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, SCREEN_W, DEFAOULT_HEIGHT - 40)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont boldSystemFontOfSize:16];
    UIColor * color = [UIColor colorWithRed:.183 green:.183 blue:.183 alpha:1];
    _label.textColor = color;
    [_label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self addSubview:_label];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 0.15;
}

+ (void)showWithMessage:(NSString *)message{
    // 1 判断屏幕方向,根据屏幕方向定位置
    // 2 视图层级关系正确
    TopViewAlert * alert = [TopViewAlert shareAlert];
    if (alert.isShow) {
        return;
    }
    alert.label.text = message;
    CGRect rect =  alert.frame;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        //竖屏
        rect.size.width = MIN_W;
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        //横屏
        rect.size.width = MAX_W;
    }
    alert.frame = rect;
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
    alert.isShow = YES;
    [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:.44 initialSpringVelocity:10 options:UIViewAnimationOptionLayoutSubviews animations:^{
        CGRect rect =  alert.frame;
        rect.origin.y = -20;
        alert.frame = rect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 delay:ANIMTED_DELAY options:0 animations:^{
            CGRect rect =  alert.frame;
            rect.origin.y = -DEFAOULT_HEIGHT;
            alert.frame = rect;
        } completion:^(BOOL finished) {
            alert.isShow = NO;
            [alert removeFromSuperview];
        }];
    }];
}

@end
