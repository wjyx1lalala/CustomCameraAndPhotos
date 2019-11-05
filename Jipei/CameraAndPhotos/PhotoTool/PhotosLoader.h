//
//  PhotosLoader.h
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//  系统图片获取工具
//  可能其中包含了iCloud状态的图片

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

//表征一个图片库资源对象
@interface JPAblumList : NSObject

@property (nonatomic, copy)   NSString *title; //相册名字
@property (nonatomic, copy)   NSString *count; //该相册内相片数量
@property (nonatomic, copy)   NSString *creationDate;//创建日期
@property (nonatomic, strong) PHAsset *headImageAsset; //相册第一张图片缩略图
@property (nonatomic, strong) PHAssetCollection *assetCollection; //相册集，通过该属性获取该相册集下所有照片
@end


@interface PhotosLoader : NSObject

+ (instancetype)sharePhotoTool;

/**
 * @brief 获取用户所有相册列表
 */
- (NSArray *)getPhotoAblumList;


/**
 * @brief 获取相册内所有图片资源
 * @param ascending 是否按创建时间正序排列 YES,创建时间正（升）序排列; NO,创建时间倒（降）序排列
 */
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;


/**
 * @brief 获取指定相册内的所有图片
 */
- (NSMutableArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection sortByCreaeteDateAscending:(BOOL)ascending;


/**
 * @brief 异步获取每个Asset对应的图片
 */
- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image))completion;

/**
 * @brief 异步获取asset对应的原始大图,allowedNet
 */
- (PHImageRequestID)requestLargeImageForAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)allowedNet completion:(void (^)(UIImage *image,BOOL isCloudImage,NSDictionary *  info))completion progressHandler:(void(^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

/**
 * @brief 根据请求的ID取消当前图片的请求
 */
- (void)cancleRequestImageByRequestID:(PHImageRequestID)requestID;

@end




