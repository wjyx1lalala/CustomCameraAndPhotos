//
//  RCTPhotoTool.m
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "RCTPhotoTool.h"
#import <React/RCTBridgeModule.h>
#import "ImagePickerController.h"
#import "PhotoLibraryController.h"

@interface RCTPhotoTool ()<RCTBridgeModule>

@end

@implementation RCTPhotoTool

RCT_EXPORT_MODULE();

// 优化，当用户点击取消的时候。也进行回调。
RCT_EXPORT_METHOD(takePhoto:(NSDictionary *)parameter andResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    if (TARGET_IPHONE_SIMULATOR) {
      resolve(@{@"errorMsg":@"模拟器不支持摄像头拍照"});
    }else{
      BOOL allowClips = NO;
      if(parameter[@"isClips"]){
        allowClips = [parameter[@"isClips"] boolValue];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        [ImagePickerController showWithAllowClips:allowClips CallBack:^(NSDictionary *info) {
          resolve(info);
        }];
      });
    }
}


RCT_EXPORT_METHOD(selectPhoto:(NSDictionary *)parameter andResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    BOOL allowiCloudNet = [parameter[@"allowiCloud"] boolValue];
    BOOL allowClips = NO;
    if(parameter[@"isClips"]){
      allowClips = parameter[@"isClips"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [PhotoLibraryController showWithSetting:allowiCloudNet andAllowClips:allowClips CallBack:^(NSDictionary *info) {
        resolve(info);
      }];
    });
}

@end
