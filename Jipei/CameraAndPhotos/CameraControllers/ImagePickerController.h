//
//  ImagePickerController.h
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 nuomi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBackBlock)(NSDictionary * info);

@interface ImagePickerController : UINavigationController

/*  拍照
 *  @allowClips 是否在拍摄结束后裁剪
 *  @callBack   拍照选择某个照片以后的回调函数
 **/
+ (void)showWithAllowClips:(BOOL)allowClips CallBack:(CallBackBlock)callBack;

@end
