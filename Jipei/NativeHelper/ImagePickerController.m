//
//  ImagePickerController.m
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 Facebook. All rights reserved.
//  本周工作要完成的几个点
//   1:拍照状态要隐藏状态栏(电池,运营商信息) 2:相册多选 3:自定义拍照页面(最好添加支持闪光灯,聚焦,前后摄像头切换,摄像头广角放大缩小等功能,本期不做强制要求) 4:图片以文件形式展示和转换base64两种支持 5:规范组件接口,强制使用propTypes,并添加注释信息,
//   6:封装loading以及错误信息弹窗工具(最好是支持两种层级关系,一种是建立在整个应用之上的,另外一种是建立在当前页面之上的)  7:js层图片查看器  8:,摄像头,图库权限申请,权限判断  9:IOS跳转系统权限设置页面
//   10:相册分组,图片格式,默认支持(png,jpeg,jpg-->warning此处不要漏掉图片数量) 11:连串认证,填写店铺信息页面具体功能,合理跳转,交互等 12:冒烟自测 13:安卓端屏幕设配,教研
//   14:安卓返回键适配 15:抽象出登录注册模块 16:连串起来用户页面随意跳转到登录注册页面,并正确回调
//   16:原生层图片查看器 17:jest添加数据测试接口

#import "ImagePickerController.h"
#import "CameraController.h"

@interface ImagePickerController ()

@property (nonatomic,copy) CallBackBlock callBack;

@end

@implementation ImagePickerController

+ (void)showWithCallBack:(CallBackBlock)callBack{
  ImagePickerController * vc =  [[self alloc] initWithRootViewController:[[CameraController alloc] init]];
  vc.callBack = callBack;
  vc.navigationBarHidden = YES;
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden{
  return [self.viewControllers firstObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
