//
//  HighSpeedImageCache.h
//  JiPei
//
//  Created by 魏家园潇 on 2017/3/20.
//  Copyright © 2017年 Facebook. All rights reserved.
//  单利类,管理高速图片缓存

#import <UIKit/UIKit.h>

@interface HighSpeedImageCache : NSObject

+ (instancetype)sharedImageCache;

//向缓存中存储图片
- (void)storeImage:(UIImage *)image forKey:(NSString *)key;

//从缓存中找图片
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;

//从缓存中删除图片
- (void)removeImageForKey:(NSString *)key;

@end
