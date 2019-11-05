//
//  CameraView.h
//  JiPei
//
//  Created by wjyx on 2017/9/30.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraViewDidClick <NSObject>

@optional
- (void)cameraViewDidClick:(CGPoint)focusPoint;
- (void)cameraViewDidPinch:(CGFloat)pinchScale;

@end

@interface CameraView : UIView

@property (nonatomic,weak) id delegate;

- (void)romoveFoucsLayer;

@end
