//
//  CameraView.m
//  JiPei
//
//  Created by wjyx on 2017/9/30.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "CameraView.h"

const CGFloat SCALE = 1.50;

@interface CameraView() <CAAnimationDelegate>

@property (nonatomic,strong) CAShapeLayer * sLayer;
@property (nonatomic,strong) UIBezierPath * focusPath;
@end

@implementation CameraView


- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
//    UIPinchGestureRecognizer * pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinches:)];
//    [self addGestureRecognizer:pinchGestureRecognizer];
  }
  return self;
}

- (void)handlePinches:(UIPinchGestureRecognizer *)pinchGestureSender{
  if (pinchGestureSender.state == UIGestureRecognizerStateEnded) {
    
  }else if(pinchGestureSender.state == UIGestureRecognizerStateBegan || pinchGestureSender.state == UIGestureRecognizerStateChanged){
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraViewDidPinch:)]) {
      [self.delegate cameraViewDidPinch:pinchGestureSender.scale];
    }
  }

}

//移除动画，移除焦点图层
- (void)romoveFoucsLayer{
  if (_sLayer) {
    [_sLayer removeAllAnimations];
    [_sLayer removeFromSuperlayer];
    _sLayer = nil;
  }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
//  [self romoveFoucsLayer];
//  
//  UITouch * touch = touches.anyObject;
//  CGPoint focusPoint = [touch locationInView:self];
//  
//  CAShapeLayer * sLayer = [self createFocusLayer:focusPoint];
//  [self.layer addSublayer:sLayer];
//  
//  CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//  anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//  anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1/SCALE, 1/SCALE, 1)];
//  anim.duration = 0.25;
//  anim.removedOnCompletion = NO;
//  anim.fillMode = kCAFillModeForwards;
//  anim.delegate = self;
//  [sLayer addAnimation:anim forKey:@"animateTransform"];
//  
//  [self setNeedsDisplay];
//  
//  if (self.delegate && [self.delegate respondsToSelector:@selector(cameraViewDidClick:)]) {
//    [self.delegate cameraViewDidClick:focusPoint];
//  }
}


- (CAShapeLayer *)createFocusLayer:(CGPoint)focusPoint{
  CGRect rect = CGRectMake(focusPoint.x - 30, focusPoint.y - 30, 60, 60);
  self.sLayer.frame = rect;
  return self.sLayer;
}

- (CAShapeLayer *)sLayer{
  if (!_sLayer) {
    CAShapeLayer * sLayer = [[CAShapeLayer alloc] init];
    sLayer.path = [self getFocusPath].CGPath;
    sLayer.strokeColor = [UIColor colorWithRed:1.0 green:219/255.0 blue:8/255.0 alpha:1].CGColor;
    sLayer.fillColor = [UIColor clearColor].CGColor;
    _sLayer = sLayer;
  }
  return _sLayer;
}

- (UIBezierPath *)getFocusPath{
  
  CGFloat scale = SCALE;
  
  UIBezierPath * focusPath = [[UIBezierPath alloc] init];
  //  focusPath set
  [focusPath setLineWidth:1.5];
  
  [focusPath moveToPoint:CGPointMake(11 * scale, 0)];
  [focusPath addLineToPoint:CGPointMake(0, 0)];
  [focusPath addLineToPoint:CGPointMake(0, 11 * scale)];
  
  [focusPath moveToPoint:CGPointMake(0, 49 * scale)];
  [focusPath addLineToPoint:CGPointMake(0, 60 * scale)];
  [focusPath addLineToPoint:CGPointMake(11 * scale, 60 * scale)];
  
  [focusPath moveToPoint:CGPointMake(49 * scale, 60 * scale)];
  [focusPath addLineToPoint:CGPointMake(60 * scale, 60 * scale)];
  [focusPath addLineToPoint:CGPointMake(60 * scale, 49 * scale)];

  [focusPath moveToPoint:CGPointMake(60 * scale, 11 * scale)];
  [focusPath addLineToPoint:CGPointMake(60 * scale, 0)];
  [focusPath addLineToPoint:CGPointMake(49 * scale, 0)];

  UIGraphicsBeginImageContext(self.bounds.size);
  [focusPath stroke];
  UIGraphicsEndImageContext();
  
  return focusPath;
}




@end
