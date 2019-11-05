//
//  PhotoLibraryController.h
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 nuomi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBackBlock)(NSDictionary * info);

@interface PhotoLibraryController : UINavigationController

@property (nonatomic,copy) CallBackBlock callBack;
@property (nonatomic,assign) BOOL allowClips;
@property (nonatomic,assign) BOOL allowiCloudNet;

+ (void)showWithSetting:(BOOL)allowiCloudNet andAllowClips:(BOOL)allowClips CallBack:(CallBackBlock)callBack;

@end
