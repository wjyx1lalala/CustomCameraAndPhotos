//
//  UIImage+clipsImage.h
//  Jipei
//
//  Created by nuomi on 2017/3/13.
//  Copyright © 2017年 nuomi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (clipsImage)

//图片转Base64
- (NSString *)transformToToBase64;

//自动剪裁一张图片为正方形
- (UIImage *)autoClipsToSquareWithSquareWidth:(CGFloat)squareWidth;

//图片裁剪为制定的大小,用于相机中部分页面
- (UIImage *)clipsImageWithSize:(CGSize)newSize;

//自动调整大小
- (UIImage *)fixOrientation;

@end
