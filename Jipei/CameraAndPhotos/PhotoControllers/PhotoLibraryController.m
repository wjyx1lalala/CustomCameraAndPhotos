//
//  PhotoLibraryController.m
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 nuomi. All rights reserved.
//

#import "PhotoLibraryController.h"
#import "PhotoGroupController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface PhotoLibraryController ()<UIGestureRecognizerDelegate>

@end

@implementation PhotoLibraryController

+ (void)showWithSetting:(BOOL)allowiCloudNet andAllowClips:(BOOL)allowClips CallBack:(CallBackBlock)callBack{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    PhotoGroupController * photos = [[PhotoGroupController alloc] init];
    PhotoLibraryController * vc =  [[self alloc] initWithRootViewController:photos];
    vc.callBack = callBack;
    vc.allowClips = allowClips;
    vc.allowiCloudNet = allowiCloudNet;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航默认标题的颜色及字体大小
    UIColor * color = [UIColor colorWithRed:.183 green:.183 blue:.183 alpha:1];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: color, NSFontAttributeName : [UIFont systemFontOfSize:19]};
    self.navigationBar.tintColor = color;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    UIImageView * hairView = [self findHairlineImageViewUnder:self.navigationBar];
    hairView.hidden = YES;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}


- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return self.viewControllers.count == 1 ? NO : YES;
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.viewControllers.count >= 1) {
        viewController.hidesBottomBarWhenPushed = YES;
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * image = [UIImage imageNamed:@"photo_return.png"];
        [backButton setImage:image forState:UIControlStateNormal];
        backButton.frame = (CGRect){CGPointZero, image.size};
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)back{
    [self popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
