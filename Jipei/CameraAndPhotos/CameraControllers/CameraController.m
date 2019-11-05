//
//  CameraController.m
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 nuomi. All rights reserved.
//  摄像 曝光 对焦 镜头缩放 前后摄像头切换431·98777
//

#import "CameraController.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

#import "CameraView.h"
#import "ImageTool.h"
#import "UIImage+clipsImage.h"
#import "ImageCropperViewController.h"


#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

const CGFloat BOTTOM_HEIGHT = 165;

@interface CameraController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,ImageCropperDelegate,CameraViewDidClick>{
  BOOL _clickTake;
  BOOL _clickUseImgae; //标记
}


@property (nonatomic,strong) CAShapeLayer * focusLayer;

//UI组件
@property (nonatomic,strong) UIButton * takePhotoButton;
@property (nonatomic,strong) UIButton * confirmButton;
@property (nonatomic,strong) UIButton * reTakePhotoButton;

@property (nonatomic,strong) UILabel * takePhotoLabel;
@property (nonatomic,strong) UILabel * confirmLabel;
@property (nonatomic,strong) UILabel * reTakePhotoLabel;

@property (nonatomic,strong) UIButton * colseButton;//右上角返回按钮
@property (nonatomic,strong) UIImageView * showImageView;//拍摄头图片的展示位置
@property (nonatomic,strong) UIView * botoomContainerView;//底部容器
//AVFoundation 摄像头组件
@property (nonatomic,strong) AVCaptureSession *session;//由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic,strong) AVCaptureStillImageOutput *captureOutput;//输出图片
@property (nonatomic,strong) AVCaptureDevice *device;//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic,strong) AVCaptureDeviceInput * input;//代表输入设备,使用AVCaptureDevice 来初始化
@property (nonatomic,strong) AVCaptureMetadataOutput * output;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer * preview;//图像预览层，实时显示捕获的图像


@end

@implementation CameraController

- (void)loadView
{
  CameraView * view = [[CameraView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  view.delegate = self;
  self.view = view;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([UIDevice currentDevice].systemVersion.doubleValue < 9.0) {
        // 针对 9.0 以下的iOS系统进行处理
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
    if ([UIDevice currentDevice].systemVersion.doubleValue < 9.0) {
        // 针对 9.0 以下的iOS系统进行处理
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setUpUI];
    [self jusdgeCanUserCamear];
}



- (void)jusdgeCanUserCamear{

    if(TARGET_IPHONE_SIMULATOR){
        [self showSimulatorAlert];
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        [self showAuthGuideAlert];
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self createCarema];
                }
            });
        }];
    }else{
       [self createCarema];
    }
}


#pragma mark - 提醒授权权限设置
- (void)showAuthGuideAlert{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString * promapt = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"选项中,允许%@访问您的相机",app_Name?app_Name:@""];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未获得授权使用摄像头" message:promapt delegate:self cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil];
    [alert show];
  
  //NSString * path = UIApplicationOpenSettingsURLString;
//    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:promapt message:nil preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction * gotoAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:path]]) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
//        }
//        [alertVC dismissViewControllerAnimated:YES completion:nil];
//    }];
//    [alertVC addAction:gotoAction];
//    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleCancel handler:nil];
//    [alertVC addAction:cancleAction];
//    //已经弹出了页面,
//#warning -- 需要修改
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self clickClose];
    }else if (buttonIndex == 1) {
        NSString * path = UIApplicationOpenSettingsURLString;
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:path]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
        }
    }
}


#pragma mark - 设置基础UI页面
- (void)setUpUI{
    self.colseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.colseButton setImage:[UIImage imageNamed:@"photograph_return"] forState:UIControlStateNormal];
    self.colseButton.frame = CGRectMake(0, 0,60, 60);
    [self.colseButton addTarget:self action:@selector(clickClose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.colseButton];
  
    _showImageView = [[UIImageView alloc] init];
    _showImageView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H - BOTTOM_HEIGHT);
    [self.view addSubview:_showImageView];
    _showImageView.hidden = YES;

    [self.view insertSubview:self.colseButton atIndex:0];

    UIView * botoom = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H - BOTTOM_HEIGHT, SCREEN_W, BOTTOM_HEIGHT)];
    botoom.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
    [self.view addSubview:botoom];
    self.botoomContainerView = botoom;

    self.takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.takePhotoButton setImage:[UIImage imageNamed:@"photograph_Button"] forState:UIControlStateNormal];
    self.takePhotoButton.frame = CGRectMake(SCREEN_W/2 - 42.5, 20,85, 85);
    [self.takePhotoButton addTarget:self action:@selector(clickTakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [botoom addSubview:self.takePhotoButton];
    UILabel * takePhotoLabel = [self createLabelWithTitle:@"点击拍照"];
    takePhotoLabel.frame = CGRectMake(SCREEN_W/2 - 42.5, 124, 85, 20);
    [botoom addSubview:takePhotoLabel];
    _takePhotoLabel = takePhotoLabel;

    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setImage:[UIImage imageNamed:@"photograph_determine"] forState:UIControlStateNormal];
    self.confirmButton.frame = CGRectMake(SCREEN_W/2 - 31.5, 32,63, 63);
    [self.confirmButton addTarget:self action:@selector(clickUseImage) forControlEvents:UIControlEventTouchUpInside];
    [botoom addSubview:self.confirmButton];
    UILabel * usePhotoLabel = [self createLabelWithTitle:@"使用照片"];
    usePhotoLabel.frame = CGRectMake(SCREEN_W/2 + 70, 109, 63, 20);
    [botoom addSubview:usePhotoLabel];
    _confirmLabel = usePhotoLabel;

    self.reTakePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.reTakePhotoButton setImage:[UIImage imageNamed:@"photograph_Remake"] forState:UIControlStateNormal];
    self.reTakePhotoButton.frame = CGRectMake(SCREEN_W/2 - 31.5, 32,63, 63);
    [self.reTakePhotoButton addTarget:self action:@selector(clickReTakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [botoom addSubview:self.reTakePhotoButton];
    UILabel * reTakePhotoLabel = [self createLabelWithTitle:@"重拍"];
    reTakePhotoLabel.frame = CGRectMake(SCREEN_W/2 - 133, 109, 63, 20);
    [botoom addSubview:reTakePhotoLabel];
    _reTakePhotoLabel = reTakePhotoLabel;
    self.confirmButton.enabled = NO;
    self.reTakePhotoButton.enabled = NO;
    self.confirmButton.alpha = 0;
    self.reTakePhotoButton.alpha = 0;
    _confirmLabel.hidden = YES;
    _reTakePhotoLabel.hidden = YES;
}

- (void)createCarema{
    // 获取设配
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 设置Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // 设置Output
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.captureOutput setOutputSettings:outputSettings];

    // Session
    self.session = [[AVCaptureSession alloc]init];

    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input]){
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:_captureOutput]){
        [self.session addOutput:_captureOutput];
    }
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = [UIScreen mainScreen].bounds;

    [self.view.layer insertSublayer:self.preview atIndex:0];
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
    //    if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
      ////自动闪关灯
    //      [_device setFlashMode:AVCaptureFlashModeAuto];
    //    }
    //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
          [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}

- (UILabel * )createLabelWithTitle:(NSString *)title{
    UILabel * label = [[UILabel alloc] init];
    label.text = title;;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

#pragma mark - 关闭页面
- (void)clickClose{
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 点击确定使用照片
- (void)clickUseImage{
    if(self.allowClips){
        ImageCropperViewController *imgEditorVC = [[ImageCropperViewController alloc] initWithImage:_showImageView.image];
        imgEditorVC.delegate = self;
        [self.navigationController pushViewController:imgEditorVC animated:YES];
    }else{
        //标记为开始剪裁
        if (_clickUseImgae) {
          return;
        }
        _clickUseImgae = YES;
        //该过程是异步的,需要处理好等待时间,免得觉得卡顿
        [ImageTool saveImgToAppWithImage:_showImageView.image complete:^(BOOL isSaveOK, NSDictionary *imageInfo) {
            _clickUseImgae = NO;
            if (isSaveOK) {
                if (self.callBack) {
                    self.callBack(imageInfo);
                }
            }else{
                self.callBack(@{@"errorMsg":@"图片保存失败"});
            }
            [self clickClose];
        }];
    }
}


#pragma mark 图片裁剪后的回调
- (void)imageCropperDidFinished:(UIImage *)editedImage {
    //处理好异步的处理的等待时间
    [ImageTool saveImgToAppWithImage:editedImage complete:^(BOOL isSaveOK, NSDictionary *imageInfo) {
        if (isSaveOK) {
            if (self.callBack) {
                self.callBack(imageInfo);
            }
        }else{
            self.callBack(@{@"errorMsg":@"图片保存失败"});
        }
        [self clickClose];
    }];
}


- (void)showSimulatorAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"模拟器不支持拍照,请使用真机调试"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - 点击拍照
- (void)clickTakePhoto{
    
    if(TARGET_IPHONE_SIMULATOR){
        [self showSimulatorAlert];
        return;
    }
    
    if(!self.captureOutput){
        //如果没有初始化,判断权限,提示用户设置
        [self jusdgeCanUserCamear];
        return;
    }
    AVCaptureConnection * videoConnection = [self.captureOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"拍照失败"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    //标记为点击
    if (_clickTake) {
      return;
    }
    _clickTake = YES;
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        _clickTake = NO;
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        //先转换图片,在做一个动画,最后开始停止session
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage* img = [UIImage imageWithData:imageData];
        [self showImg:img];
        //stopRunning 耗时比较长 293.323994 ms 大概0.3S  最后停止session
        [self.session stopRunning];
    }];
  
}


- (void)showImg:(UIImage *)image{
  
    [self.view bringSubviewToFront:_colseButton];
    CGFloat height = image.size.height * ((SCREEN_H - BOTTOM_HEIGHT)/SCREEN_H);
    CGSize newsize = CGSizeMake(image.size.width, height);
    image= [image clipsImageWithSize:newsize];
    _showImageView.image = image;
    _showImageView.backgroundColor = [UIColor redColor];
    [self.view addSubview: _showImageView];
    [self.view bringSubviewToFront:self.colseButton];
    _showImageView.hidden = NO;
    _takePhotoLabel.hidden = YES;

    _confirmLabel.hidden = NO;
    _reTakePhotoLabel.hidden = NO;
    _confirmLabel.alpha = 0;
    _reTakePhotoLabel.alpha = 0;

    //开始动画
    self.confirmButton.alpha = 1;
    self.reTakePhotoButton.alpha = 1;
    self.takePhotoButton.enabled = NO;
    [UIView animateWithDuration:.35 animations:^{
        self.takePhotoButton.alpha = 0;
        self.confirmButton.frame = CGRectMake(SCREEN_W/2 + 70, 32,63, 63);
        self.reTakePhotoButton.frame = CGRectMake(SCREEN_W/2 - 133, 32,63, 63);
    } completion:^(BOOL finished) {
        self.confirmButton.enabled = YES;
        self.reTakePhotoButton.enabled = YES;
    }];
    [UIView animateWithDuration:0.1 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _confirmLabel.alpha = 1;
        _reTakePhotoLabel.alpha = 1;
    } completion:nil];
}



#pragma mark - 点击重新拍照
- (void)clickReTakePhoto{
    [self.session startRunning];
    _showImageView.image = nil;
    _showImageView.hidden = YES;
    self.takePhotoButton.enabled = YES;
    _confirmLabel.hidden = YES;
    _reTakePhotoLabel.hidden = YES;
    //返回动画
    [UIView animateWithDuration:.35 animations:^{
        self.confirmButton.frame = CGRectMake(SCREEN_W/2 - 31.5, 32,63, 63);
        self.reTakePhotoButton.frame = CGRectMake(SCREEN_W/2 - 31.5, 32,63, 63);
    } completion:^(BOOL finished) {
        self.confirmButton.enabled = YES;
        self.reTakePhotoButton.enabled = YES;
        self.confirmButton.alpha = 0;
        self.reTakePhotoButton.alpha = 0;
    }];
    [UIView animateWithDuration:.2 delay:.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.takePhotoButton.alpha = 1;
    } completion:^(BOOL finished) {
        _takePhotoLabel.hidden = NO;
    }];
}


#pragma - 保存至系统的相册
//- (void)saveImageToPhotoAlbum:(UIImage*)savedImage{
//    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//}
//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
//    NSString *msg = error ? @"保存图片失败" : @"保存图片成功";
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                    message:msg
//                                                   delegate:self
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil];
//    [alert show];
//}


//#pragma - 切换摄像头
//- (void)changeCamera{
//    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
//    if (cameraCount > 1) {
//        //有些微卡顿情况发生
//        NSError *error;
//        CATransition *animation = [CATransition animation];
//        animation.duration = .2f;
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        animation.type = @"oglFlip";
//        AVCaptureDevice *newCamera = nil;
//        AVCaptureDeviceInput *newInput = nil;
//        AVCaptureDevicePosition position = [[_input device] position];
//        if (position == AVCaptureDevicePositionFront){
//            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
//            animation.subtype = kCATransitionFromLeft;
//        }else {
//            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
//            animation.subtype = kCATransitionFromRight;
//        }
//        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
//        [self.preview addAnimation:animation forKey:nil];
//        if (newInput != nil) {
//            [self.session beginConfiguration];
//            [self.session removeInput:_input];
//            if ([self.session canAddInput:newInput]) {
//                [self.session addInput:newInput];
//                self.input = newInput;
//            } else {
//                [self.session addInput:self.input];
//            }
//            [self.session commitConfiguration];
//        } else if (error) {
//            NSLog(@"toggle carema failed, error = %@", error);
//        }
//    }
//}
//
//


- (void)cameraViewDidPinch:(CGFloat)pinchScale{
  NSLog(@"%.2f",pinchScale);
}


//注意及时清空焦点。拍照结束，停止聚焦

//#pragma mark - 聚焦
- (void)cameraViewDidClick:(CGPoint)focusPoint{
  [self.view bringSubviewToFront:self.botoomContainerView];
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([self.device isFocusPointOfInterestSupported]) {
            [self.device setFocusPointOfInterest:focusPoint];
        }
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([self.device isExposurePointOfInterestSupported]) {
            [self.device setExposurePointOfInterest:focusPoint];
        }
        [self.device unlockForConfiguration];
    }
    
}

//
//- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//    for ( AVCaptureDevice *device in devices )
//        if ( device.position == position ) return device;
//    return nil;
//}

- (void)dealloc{
    self.session = nil;
    self.captureOutput = nil;
    self.device = nil;
    self.input = nil;
    self.output = nil;
    self.preview = nil;
    self.callBack = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
