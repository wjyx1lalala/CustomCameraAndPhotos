//
//  UIImage+clipsImage.m
//  Jipei
//
//  Created by nuomi on 2017/3/13.
//  Copyright © 2017年 nuomi. All rights reserved.
//

#import "UIImage+clipsImage.h"

@implementation UIImage (clipsImage)


#pragma mark - 图片转base64
- (NSString *)transformToToBase64{
  /*
   NSData * dd = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
   UIImage * img = [[UIImage alloc] initWithData:dd];
   UIImageView * imgV = [[UIImageView alloc] initWithImage:img];
   imgV.frame = CGRectMake(0, 0, 100, 100);
   [self.view addSubview:imgV];
   */
  NSData * imageData = UIImageJPEGRepresentation(self,1);
  return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}



- (UIImage *)autoClipsToSquareWithSquareWidth:(CGFloat)squareWidth{
  
  //截取图片中的一部分
//  CGRect newRect  =  CGRectMake(0, 0, squareWidth, squareWidth);
//  CGImageRef imageRef=CGImageCreateWithImageInRect([self CGImage],newRect);
//  CGImageRelease(imageRef);
//  UIImage *image1=[UIImage imageWithCGImage:imageRef];
//  return image1;
  
    //裁剪图片耗时
//    NSDate* tmpStartDate = [NSDate date];
    UIImage * newImage = self;
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (self.size.width > self.size.height) {
        //image原始高度为200，缩放image的高度为400pixels，所以缩放比率为2
        CGFloat scaleRatio = squareWidth / self.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        //设置绘制原始图片的画笔坐标为CGPoint(-100, 0)pixels
        origin = CGPointMake(-(self.size.width - self.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = squareWidth / self.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(0, -(self.size.height - self.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(ceil(squareWidth), ceil(squareWidth));
    //创建画板为(400x400)pixels
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //绘制底层为白色
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextDrawPath(context, kCGPathFillStroke);//绘制填充
    //将image原始图片(400x200)pixels缩放为(800x400)pixels
    CGContextConcatCTM(context, scaleTransform);
    //origin也会从原始(-100, 0)缩放到(-200, 0)
    [self drawAtPoint:origin];
    
    //获取缩放后剪切的image图片
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartDate];
//    NSLog(@"clipsToSquare cost time = %f ms", deltaTime *1000.0);
    return newImage;
    
}

- (UIImage *)clipsImageWithSize:(CGSize)newSize{
    
    //裁剪图片耗时
    NSDate* tmpStartDate = [NSDate date];
    
    //先调整图片方向
    UIImage * image = [self fixOrientation];
    CGImageRef imageRef = image.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, CGRectMake(0, 0, newSize.width, newSize.height - 1));
    UIImage *cropImage = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartDate];
    NSLog(@"clipsImage cost time = %f ms", deltaTime *1000.0);
    return cropImage;
}


- (UIImage *)fixOrientation {
  
  // No-op if the orientation is already correct
  if (self.imageOrientation == UIImageOrientationUp) return self;
  
  // We need to calculate the proper transformation to make the image upright.
  // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  switch (self.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
      
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
      
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, 0, self.size.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
    case UIImageOrientationUp:
    case UIImageOrientationUpMirrored:
      break;
  }
  
  switch (self.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
      
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    case UIImageOrientationUp:
    case UIImageOrientationDown:
    case UIImageOrientationLeft:
    case UIImageOrientationRight:
      break;
  }
  
  // Now we draw the underlying CGImage into a new context, applying the transform
  // calculated above.
  CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                           CGImageGetBitsPerComponent(self.CGImage), 0,
                                           CGImageGetColorSpace(self.CGImage),
                                           CGImageGetBitmapInfo(self.CGImage));
  CGContextConcatCTM(ctx, transform);
  switch (self.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      // Grr...
      CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
      break;
      
    default:
      CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
      break;
  }
  
  // And now we just create a new UIImage from the drawing context
  CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
  UIImage *img = [UIImage imageWithCGImage:cgimg];
  CGContextRelease(ctx);
  CGImageRelease(cgimg);
  if(img){
    return img;
  }else{
    return self;
  }
  
}


@end
