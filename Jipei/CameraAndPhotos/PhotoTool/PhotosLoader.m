//
//  PhotosLoader.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//  

#import "PhotosLoader.h"
#import "HighSpeedImageCache.h"
#import "UIImage+clipsImage.h"

@implementation JPAblumList

@end

@implementation PhotosLoader

static PhotosLoader *sharePhotoTool = nil;
+ (instancetype)sharePhotoTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [[self alloc] init];
    });
    return sharePhotoTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [super allocWithZone:zone];
    });
    return sharePhotoTool;
}

#pragma mark - 获取所有相册列表
- (NSMutableArray *)getPhotoAblumList
{
    NSMutableArray *photoAblumList = [NSMutableArray array];
    
    //获取所有系统智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        //过滤掉视频和最近删除
        if (!([collection.localizedTitle isEqualToString:@"Recently Deleted"] ||
              [collection.localizedTitle isEqualToString:@"Videos"] || [collection.localizedTitle isEqualToString:@"最近删除"] || [collection.localizedTitle isEqualToString:@"视频"])) {
            NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection sortByCreaeteDateAscending:NO];
            if (assets.count > 0) {
                JPAblumList * list = [[JPAblumList alloc] init];
                PHAsset * as = [assets firstObject];
                list.title = collection.localizedTitle;
              //英文语言的时候,需要转换一下图库名字的格式
              //[self transformAblumTitle:collection.localizedTitle];
                list.count = [NSString stringWithFormat:@"%ld",(long)assets.count];
                list.headImageAsset = assets.firstObject;
                list.assetCollection = collection;
                list.creationDate = [NSString stringWithFormat:@"%ld",(long)[as.creationDate  timeIntervalSince1970]];
                [photoAblumList addObject:list];
            }
        }
    }];
    
    //获取用户创建的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection sortByCreaeteDateAscending:NO];
        if (assets.count > 0) {
            JPAblumList * list = [[JPAblumList alloc] init];
            PHAsset * as = [assets firstObject];
            list.title = collection.localizedTitle;
            list.count = [NSString stringWithFormat:@"%ld",(long)assets.count];
            list.headImageAsset = assets.firstObject;
            list.assetCollection = collection;
            list.creationDate = [NSString stringWithFormat:@"%ld",(long)[as.creationDate  timeIntervalSince1970]];
            [photoAblumList addObject:list];
        }
    }];
    
    NSArray *resultArr = [photoAblumList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        //排序  按照最后的修改日期排序
        NSString * stamp1 =  ((JPAblumList *)obj1).creationDate;
        NSString * stamp2 =  ((JPAblumList *)obj2).creationDate;
        NSComparisonResult result = [stamp1 compare:stamp2 options:NSCaseInsensitiveSearch];
        return result == NSOrderedAscending; //升序
    }];
    photoAblumList = nil;
    photoAblumList = [NSMutableArray array];
    for (JPAblumList * model in resultArr) {
        if ([model.title isEqualToString:@"所有照片"] || [model.title isEqualToString:@"All Photos"] ) {
            [photoAblumList insertObject:model atIndex:0];
        }else{
            [photoAblumList addObject:model];
        }
    }
    return photoAblumList;
}

#pragma mark - 转换图库的名字
- (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    } else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    }
    return @"";
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

#pragma mark - 获取相册内所有照片资源
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列;降序排列以后,图片最新的在数组最前面
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    return assets;
}

#pragma mark - 获取指定相册内的所有图片
//ascending YES 表示升序
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection sortByCreaeteDateAscending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

#pragma mark - 异步获取asset对应的缩略图片
- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
//    /**
//     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
//     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
//     这个属性只有在 synchronous 为 true 时有效。
//     */
//    option.normalizedCropRect = CGRectMake(0, 0, size.width * 3.0, size.width * 3.0);
//    option.resizeMode = PHImageRequestOptionsResizeModeExact;//控制照片尺寸
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;//控制照片质量
    option.synchronous = NO;//不能同步,否则会卡顿
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    return [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        if (completion) {
          completion(image);
        }
    }];
}


#pragma mark - 异步获取asset对应的原始大图
- (PHImageRequestID)requestLargeImageForAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)allowedNet completion:(void (^)(UIImage *image,BOOL isCloudImage,NSDictionary * info))completion progressHandler:(void(^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler{
  
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = allowedNet;
    options.synchronous = NO;
    options.normalizedCropRect = CGRectMake(0, 0, 100, 100);
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    //进度
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info){
      if (progressHandler) {
        if ([NSThread currentThread].isMainThread) {
          progressHandler(progress,error,stop,info);
        }else{
          dispatch_async(dispatch_get_main_queue(), ^{
            progressHandler(progress,error,stop,info);
          });
        }
      }
    };
    //请求或者网络下载原始图片
    return [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL isICloud = [info[PHImageResultIsInCloudKey] boolValue];
        if (completion) {
          if (![NSThread currentThread].isMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
              completion(image,isICloud,info);
            });
          }else{
            completion(image,isICloud,info);
          }
        }
    }];
}


#pragma mark - 取消图片的请求
- (void)cancleRequestImageByRequestID:(PHImageRequestID)requestID{
    [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
}


@end


