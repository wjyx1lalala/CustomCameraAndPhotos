//
//  ClipImageViewController.h
//  拍照测试
//
//  Created by wjyx on 2017/4/14.
//  Copyright © 2017年 魏家园潇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageCropperViewController;

@protocol ImageCropperDelegate <NSObject>

/**
 *  用户裁剪图片后的回调
 *
 *  cropperViewController      裁剪ViewController
 *  editedImage                裁剪后的图片
 */
- (void)imageCropperDidFinished:(UIImage *)editedImage;

@end

@interface ImageCropperViewController : UIViewController

@property (nonatomic, assign) id<ImageCropperDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;

- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

- (instancetype)initWithImage:(UIImage *)originalImage;

@end
