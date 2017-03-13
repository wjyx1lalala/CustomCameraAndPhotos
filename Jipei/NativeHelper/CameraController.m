//
//  CameraController.m
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

const CGFloat BOTTOM_HEIGHT = 165;

@interface CameraController ()<AVCaptureMetadataOutputObjectsDelegate>


//UI组件
@property (nonatomic,strong) UIButton * takePhotoButton;
@property (nonatomic,strong) UIButton * confirmButton;
@property (nonatomic,strong) UIButton * reTakePhotoButton;

@property (nonatomic,strong) UILabel * takePhotoLabel;
@property (nonatomic,strong) UILabel * confirmLabel;
@property (nonatomic,strong) UILabel * reTakePhotoLabel;

@property (nonatomic,strong) UIButton * colseButton;//右上角返回按钮

@property (nonatomic,strong) UIImageView * showImageView;

//AVFoundation 摄像头组件
@property (nonatomic,strong) AVCaptureSession *session;//由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic,strong) AVCaptureStillImageOutput *captureOutput;//输出图片
@property (nonatomic,strong) AVCaptureDevice *device;//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）

@property (nonatomic,strong) AVCaptureDeviceInput * input;//代表输入设备,使用AVCaptureDevice 来初始化
@property (nonatomic,strong) AVCaptureMetadataOutput * output;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer * preview;//图像预览层，实时显示捕获的图像


@end

@implementation CameraController


- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  [self setUpUI];
    [self jusdgeCanUserCamear];
  // Do any additional setup after loading the view.
}

- (void)jusdgeCanUserCamear{
    
  AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  if (authStatus == AVAuthorizationStatusDenied) {
    [self showAuthGuideAlert];
  }else if(authStatus == AVAuthorizationStatusNotDetermined){
      [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
          dispatch_async(dispatch_get_main_queue(), ^{
              if (granted) {
                  [self createCarema];
              }else{
                  [self showAuthGuideAlert];
              }
          });
      }];
  }else{
     [self createCarema];
  }
}

#pragma mark - 跳转权限页面
- (void)showAuthGuideAlert{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString * promapt = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相册\"选项中,允许%@访问你的相机",app_Name];
#warning -- 路径设置有问题
    NSString * path = @"prefs:root=Privacy&path=CAMERA";
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:promapt message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * gotoAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:path]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
        }
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:gotoAction];
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancleAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
}


// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    NSLog(@"%.4f",pinchGestureRecognizer.scale);
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //手势开始
//        if (pinchGestureRecognizer.scale) {
//            view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
//        }else{
//            
//        }
    }else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded){
        //手势结束
    }else if (pinchGestureRecognizer.state == UIGestureRecognizerStateCancelled){
       //取消
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    NSLog(@"%@",panGestureRecognizer);
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"手势取消");
    }
}




- (void)setUpUI{
  
  self.colseButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.colseButton setImage:[UIImage imageNamed:@"photograph_return"] forState:UIControlStateNormal];
  const CGFloat size = 20;
  self.colseButton.frame = CGRectMake(size, size,size, size);
  [self.colseButton addTarget:self action:@selector(clickClose) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.colseButton];
  
    
    
    _showImageView = [[UIImageView alloc] init];
    _showImageView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H - BOTTOM_HEIGHT);
    [self.view addSubview:_showImageView];
    _showImageView.hidden = YES;
    [_showImageView setUserInteractionEnabled:YES];
    [_showImageView setMultipleTouchEnabled:YES];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
//    pinchGestureRecognizer.scale = 1;
    [_showImageView addGestureRecognizer:pinchGestureRecognizer];
    
  
  UIView * botoom = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H - BOTTOM_HEIGHT, SCREEN_W, BOTTOM_HEIGHT)];
  botoom.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
  [self.view addSubview:botoom];
  
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
  CGFloat layerWidth = self.view.bounds.size.width;
    CGFloat layerHeight = self.view.bounds.size.height - 165;
  self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
  self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
  self.preview.frame = CGRectMake(0, 0,layerWidth, layerHeight);
  [self.view.layer insertSublayer:self.preview atIndex:0];
  [self.session startRunning];
  if ([_device lockForConfiguration:nil]) {
    if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
      [_device setFlashMode:AVCaptureFlashModeAuto];
    }
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
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}

#pragma mark - 关闭页面
- (void)clickClose{
  NSLog(@"关闭页面");
}

#pragma mark - 点击确定使用照片
- (void)clickUseImage{
  NSLog(@"点击确定使用照片");
  
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 点击拍照
- (void)clickTakePhoto{
  //通过sessio来截取画面
  
  AVCaptureConnection * videoConnection = [self.captureOutput connectionWithMediaType:AVMediaTypeVideo];
  if (!videoConnection) {
    NSLog(@"take photo failed!");
    return;
  }
  
  [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    if (imageDataSampleBuffer == NULL) {
      return;
    }
      [self.session stopRunning];
    NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage* img = [UIImage imageWithData:imageData];
    [self showImg:img];
  }];
  
}


- (UIImage*)scaleFromImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    
    CGRect partRect = CGRectMake(0, 0, newSize.width , newSize.height);
    CGImageRef imagePartRef = CGImageCreateWithImageInRect([image CGImage],partRect);
    CGFloat deviceScale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(partRect.size, NO, deviceScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, partRect.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, partRect.size.width, partRect.size.height), imagePartRef);
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imagePartRef);
    if (newImg.size.width != partRect.size.width || newImg.size.height != partRect.size.height ) {
        NSLog(@"剪裁不符合要求啊");
    }else{
        NSLog(@"裁剪符合要求了");
    }
    return newImg;
}



- (void)showImg:(UIImage *)image{
    
    CGFloat height = image.size.height * ((SCREEN_H - BOTTOM_HEIGHT)/SCREEN_H);
    CGSize size = CGSizeMake(image.size.width, height);
    image = [self scaleFromImage:image scaledToSize:size];
    [self saveImageToPhotoAlbum:image];
    NSLog(@"裁剪后,image的尺寸%@",NSStringFromCGSize(image.size));
    _showImageView.image = image;
    
  [self.view bringSubviewToFront:_showImageView];
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
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        msg = @"保存图片成功" ;
    }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
