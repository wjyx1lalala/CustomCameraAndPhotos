//
//  HighSpeedImageCache.m
//  JiPei
//
//  Created by 魏家园潇 on 2017/3/20.
//  Copyright © 2017年 Facebook. All rights reserved.
//  图片缓存,用于优化

#import "HighSpeedImageCache.h"

@interface HighSpeedImageCache ()

@property (nonatomic,strong) NSCache * imagesCache;

@end

@implementation HighSpeedImageCache

static HighSpeedImageCache * shareinstance = nil;

+ (instancetype)sharedImageCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      shareinstance = [[HighSpeedImageCache alloc] init];
    });
    return shareinstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      shareinstance = [super allocWithZone:zone];
    });
    return shareinstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
      self.imagesCache = [[NSCache alloc] init];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key{
    if (image && key) {
      [self.imagesCache setObject:image forKey:key];
    }
}

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key{
    return [self.imagesCache objectForKey:key];
}

- (void)removeImageForKey:(NSString *)key{
    [self.imagesCache removeObjectForKey:key];
}

- (void)clearCache{
    [self.imagesCache removeAllObjects];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end
