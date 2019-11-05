//
//  CameraController.h
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 nuomi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBackBlock)(NSDictionary * info);

@interface CameraController : UIViewController

@property (nonatomic,copy) CallBackBlock callBack; //拍摄完成后选择某张照片的回调
@property (nonatomic,assign) BOOL allowClips; //是否拍摄后裁剪

@end
