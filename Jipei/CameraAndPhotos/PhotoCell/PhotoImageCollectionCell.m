//
//  PhotoImageCollectionCell.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "PhotoImageCollectionCell.h"
#import "TopViewAlert.h"
#import "PhotosLoader.h"
#import "UIImage+clipsImage.h"
#import "HighSpeedImageCache.h"
#import "ImageTool.h"

static NSString * AddNotificationName = @"PhotoImageCollectionCellAddGesture";//添加手势通知的名字
static NSString * DelNotificationName = @"PhotoImageCollectionCellDidClick";//移除通知的名字
static NSString * BanAllowedICloudNetKey = @"BanAllowedICloudNetKey";//是否禁止iCloud下载

@interface PhotoImageCollectionCell (){
  BOOL _selected;
}

@property (nonatomic,strong) UIImageView *imgV;//图片
@property (nonatomic,strong) UIImageView * selctedView;//是否选中图片

@property (nonatomic,strong) CALayer * loadingBackLayer;//底色图片颜色
@property (nonatomic,strong) CAShapeLayer * ringShapeLayer;//边框环形颜色
@property (nonatomic,strong) CAShapeLayer * fanShapeLayer;//扇形进度

@property (nonatomic,copy) NSString * downLoadingLocalIdentifier;
@property (nonatomic,assign) double downLoadingProgress;



@end

@implementation PhotoImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI{
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allowUse) name:AddNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remove) name:DelNotificationName object:nil];
  
    _imgV = [[UIImageView alloc] init];
    _imgV.layer.borderWidth = 0.5;
    _imgV.layer.borderColor = [UIColor whiteColor].CGColor;
    _imgV.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
    [_imgV addGestureRecognizer:tap];
    [self.contentView addSubview:_imgV];
  
    //约束图片
    _imgV.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * centerX = [NSLayoutConstraint constraintWithItem:_imgV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint * centerY = [NSLayoutConstraint constraintWithItem:_imgV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraints:@[centerX,centerY]];
  
    _selctedView = [[UIImageView alloc] init];
    _selctedView.image = [UIImage imageNamed:@"photograph_choose.png"];
    [self.contentView addSubview:_selctedView];
  
    //约束左上角的已选按钮
    NSLayoutConstraint * width = [NSLayoutConstraint constraintWithItem:_selctedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:22.5];
    NSLayoutConstraint * height = [NSLayoutConstraint constraintWithItem:_selctedView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:22.5];
    NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_selctedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:5];
    NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:_selctedView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-5];
    //约束选中按钮
    _selctedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[width,height,top,right]];
  
}

- (void)allowUse{
    _imgV.userInteractionEnabled = YES;
    if (_selected) {
        [self showDeselcted];
    }
}

- (void)remove{
    //#warning -- 如果是单个选择的话,需要禁止
    _imgV.userInteractionEnabled = NO;
}


//#warning -- 暂时有同时点击选中的bug 
- (void)clickImageView:(UITapGestureRecognizer *)tap{
    CGPoint p = [tap locationInView:self];
    CGFloat cellW = self.bounds.size.width;
    //点击之后 锁定屏幕不许点击
    if (self.delegate && [self.delegate respondsToSelector:@selector(springAnimatedStart)]) {
        [self.delegate springAnimatedStart];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DelNotificationName object:nil];
    [[PhotosLoader sharePhotoTool] requestLargeImageForAsset:self.asset networkAccessAllowed:NO completion:^(UIImage *image, BOOL isCloudImage,NSDictionary *  info) {
        NSURL * filePathUrl = info[@"PHImageFileURLKey"];//图片的路径
        NSString * filePath = [filePathUrl absoluteString];
        if (image && filePath) {
          //filePathUrl 可能为空
          if((cellW- p.x)<35 && p.y<35){
            [self showSelcted];
          }
          //延迟进行回调,可以委婉的显示选中效果
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //先进行回调代理点击的图片
            if ([self.delegate respondsToSelector:@selector(clickImageWithImage:andFilePath:andPop:andIndex:)]) {
                if((cellW- p.x)<35 && p.y<35){
                  [self.delegate clickImageWithImage:image andFilePath:filePath andPop:YES andIndex:self.index];
                }else{
                  [self.delegate clickImageWithImage:image andFilePath:filePath andPop:NO andIndex:self.index];
                }
              }
          });
        }else if (isCloudImage){
            if (self.allowiCloudNet) {
                [self showIcloudAlert];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:AddNotificationName object:nil];
                [TopViewAlert showWithMessage:@"请在系统相册中下载iCloud图片后重试"];
            }
        }else if (image){
            //对应p过的照片
          if((cellW - p.x)<35 && p.y<35){
            [self showSelcted];
          }
          [ImageTool saveImgToAppWithImage:image complete:^(BOOL isSaveOK, NSDictionary *imageInfo) {
            if(!isSaveOK){
              [[NSNotificationCenter defaultCenter] postNotificationName:DelNotificationName object:nil];
              if ([self.delegate respondsToSelector:@selector(clickImageWithImage:andFilePath:andPop:andIndex:)]) {
                [self.delegate clickImageWithImage:nil andFilePath:nil andPop:YES andIndex:self.index];
              }
            }else{
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(clickImageWithImage:andFilePath:andPop:andIndex:)]) {
                  if((cellW- p.x)<35 && p.y<35){
                    [self.delegate clickImageWithImage:image andFilePath:imageInfo[@"filePath"] andPop:YES andIndex:self.index];
                  }else{
                    [self.delegate clickImageWithImage:image andFilePath:imageInfo[@"filePath"] andPop:NO andIndex:self.index];
                  }
                }
              });
            }
          }];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:DelNotificationName object:nil];
            if ([self.delegate respondsToSelector:@selector(clickImageWithImage:andFilePath:andPop:andIndex:)]) {
              [self.delegate clickImageWithImage:nil andFilePath:nil andPop:YES andIndex:self.index];
            }
        }
    } progressHandler:nil];
  
}

- (void)showSelcted{
    [[NSNotificationCenter defaultCenter] postNotificationName:DelNotificationName object:nil];
    _selctedView.image = [UIImage imageNamed:@"photograph_choose_touch.png"];
    [UIView animateWithDuration:.1 animations:^{
      _selctedView.transform = CGAffineTransformScale(_imgV.transform, 1.1, 1.1);
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:.2 delay:0 usingSpringWithDamping:.35 initialSpringVelocity:7 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _selctedView.transform = CGAffineTransformScale(_imgV.transform, .9, .9);
      } completion:^(BOOL finished) {
          if (self.delegate && [self.delegate respondsToSelector:@selector(springAnimatedEnd)]) {
              [self.delegate springAnimatedEnd];
          }
      }];
    }];
    _selected = YES;
}

- (void)showDeselcted{
    _selctedView.image = [UIImage imageNamed:@"photograph_choose.png"];
    [UIView animateWithDuration:.1 animations:^{
        _selctedView.transform = CGAffineTransformScale(_imgV.transform, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:0 usingSpringWithDamping:.35 initialSpringVelocity:7 options:UIViewAnimationOptionLayoutSubviews animations:^{
            _selctedView.transform = CGAffineTransformScale(_imgV.transform, .9, .9);
        } completion:nil];
    }];
    _selected = NO;
}

- (void)startDownload{
  
  if([self.delegate respondsToSelector:@selector(startiCloudImageLoading)]){
    [self.delegate startiCloudImageLoading];
  }
  
  self.downLoadingLocalIdentifier = self.asset.localIdentifier;
  
  [[PhotosLoader sharePhotoTool] requestLargeImageForAsset:self.asset networkAccessAllowed:YES completion:^(UIImage *image, BOOL isCloudImage,NSDictionary *  info) {
    
      self.downLoadingLocalIdentifier = nil;
      if([self.delegate respondsToSelector:@selector(finishiCloudImageLoading)]){
        [self.delegate finishiCloudImageLoading];
      }
      [self removeLoadingLayer];
      NSURL * filePathUrl = info[@"PHImageFileURLKey"];//图片的路径
      NSString * filePath = [filePathUrl resourceSpecifier];
      if (image && filePath) {
          [self showSelcted];
          //延迟进行回调,可以委婉的显示选中效果
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.32 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              //先进行回调代理点击的图片
              if ([self.delegate respondsToSelector:@selector(clickImageWithImage:andFilePath:andPop:andIndex:)]) {
                  [self.delegate clickImageWithImage:image andFilePath:filePath andPop:YES andIndex:self.index];
              }
          });
      }else{
          [[NSNotificationCenter defaultCenter] postNotificationName:DelNotificationName object:nil];
          if ([self.delegate respondsToSelector:@selector(clickImageWithImage:andFilePath:andPop:andIndex:)]) {
              [self.delegate clickImageWithImage:nil andFilePath:nil andPop:YES andIndex:self.index];
          }
      }
  } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
      self.downLoadingProgress = progress;
      if (!*stop) {
        NSLog(@"进度%f",progress);
        [self showImageLoadingProgress:progress];
      }else{
        [self removeLoadingLayer];
      }
      if (error) {
        self.downLoadingLocalIdentifier = nil;
      }
  }];
}


- (void)removeLoadingLayer{
    if (_loadingBackLayer || _ringShapeLayer || _fanShapeLayer) {
      [_loadingBackLayer removeFromSuperlayer];
      [_ringShapeLayer removeFromSuperlayer];
      [_fanShapeLayer  removeFromSuperlayer];
    }
    _loadingBackLayer = nil;
    _ringShapeLayer = nil;
    _fanShapeLayer = nil;
}

- (void)showImageLoadingProgress:(CGFloat)progress{
    if (![self.downLoadingLocalIdentifier isEqualToString:self.asset.localIdentifier]) {
        [self removeLoadingLayer];
        return;
    }
    
    if (!_loadingBackLayer) {
        CGFloat width = _imgV.frame.size.width;
        _loadingBackLayer = [CALayer layer];
        _loadingBackLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2].CGColor;
        _loadingBackLayer.frame = CGRectMake(0, 0, width, width);;
        _loadingBackLayer.position = _imgV.center;
        [_imgV.layer addSublayer:_loadingBackLayer];
        
        _ringShapeLayer = [[CAShapeLayer alloc] init];
        _ringShapeLayer.bounds = CGRectMake(0, 0, 60, 60);
        _ringShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _ringShapeLayer.lineWidth = 2.0;
        _ringShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        CGRect frame = CGRectMake(0, 0, 60, 60);
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:frame];
        _ringShapeLayer.path = circlePath.CGPath;
        _ringShapeLayer.position = _imgV.center;
        [_imgV.layer addSublayer:_ringShapeLayer];
        
        _fanShapeLayer =  [[CAShapeLayer alloc] init];
        _fanShapeLayer.bounds = CGRectMake(0, 0, width, width);
        _fanShapeLayer.fillColor = [UIColor whiteColor].CGColor;
        _fanShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        _fanShapeLayer.position = _imgV.center;
        [_imgV.layer addSublayer:_fanShapeLayer];
    }
    
    //设置扇形的 CAShapeLayer与UIBezierPath 重新关联
    UIBezierPath * fanPath = [UIBezierPath bezierPathWithArcCenter:_imgV.center radius:26 startAngle: -M_PI_2  endAngle:((progress * 2 * M_PI) - M_PI_2) clockwise:YES];
    [fanPath addLineToPoint:_imgV.center];
    [fanPath closePath];
    _fanShapeLayer.path = fanPath.CGPath;
}


#pragma mark - iCloud下载提示
- (void)showIcloudAlert{
    NSString *msg = @"iCloud图片,是否启用网络下载高清图";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"开启",nil];
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
      if([self.delegate respondsToSelector:@selector(finishiCloudImageLoading)]){
        [self.delegate finishiCloudImageLoading];
      }
        [[NSNotificationCenter defaultCenter] postNotificationName:AddNotificationName object:nil];
    }else if (buttonIndex == 1) {
        [self startDownload];
    }
}

#pragma mark - 即将重用的时候调用
- (void)prepareForReuse{
    [super prepareForReuse];
    self.imgV.image = nil;
}

//cell复用,一定要防止内容复用
- (void)setAsset:(PHAsset *)asset{
  
    _asset = asset;
    NSString * localIdentifier = asset.localIdentifier;
    //先从全部缓存中找图片,如果没有去图库中请求,
    UIImage * image = [[HighSpeedImageCache sharedImageCache] imageFromMemoryCacheForKey:localIdentifier];
    if (image) {
        self.imgV.image = image;
    }else{
        CGSize size =  CGSizeMake(self.frame.size.width, self.frame.size.width);
        [[PhotosLoader sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            if (image) {
                UIImage * clipsImage = [image autoClipsToSquareWithSquareWidth:size.width];
                self.imgV.image = clipsImage;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [[HighSpeedImageCache sharedImageCache] storeImage:clipsImage forKey:localIdentifier];
                });
            }
        }];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

