//
//  ImagePickerController.h
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBackBlock)(NSDictionary * info);

@interface ImagePickerController : UINavigationController

+ (void)showWithCallBack:(CallBackBlock)callBack;

@end
