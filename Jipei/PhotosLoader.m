//
//  PhotosLoader.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "PhotosLoader.h"


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
- (NSArray *)getPhotoAblumList
{
    NSMutableArray *photoAblumList = [NSMutableArray array];
    
    //获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        //过滤掉视频和最近删除
        if (!([collection.localizedTitle isEqualToString:@"Recently Deleted"] ||
              [collection.localizedTitle isEqualToString:@"Videos"])) {
            NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
            if (assets.count > 0) {
                PHAsset * as = [assets firstObject];
                NSDictionary * dict = @{@"title":[self transformAblumTitle:collection.localizedTitle],
                                        @"count":[NSString stringWithFormat:@"%ld",(long)assets.count],
                                        @"headImageAsset":assets.firstObject,
                                        @"assetCollection":collection,
                                        @"creationDate":[NSString stringWithFormat:@"%ld",(long)[as.creationDate  timeIntervalSince1970]]};
                [photoAblumList addObject:dict];
            }
        }
    }];
    
    //获取用户创建的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
        if (assets.count > 0) {
            PHAsset * as = [assets firstObject];
            NSDictionary * dict = @{@"title":collection.localizedTitle,
                                    @"count":[NSString stringWithFormat:@"%ld",(long)assets.count],
                                    @"headImageAsset":assets.firstObject,
                                    @"assetCollection":collection,
                                    @"creationDate":[NSString stringWithFormat:@"%ld",(long)[as.creationDate  timeIntervalSince1970]]};
            [photoAblumList addObject:dict];
        }
    }];
    
    NSArray *resultArr = [photoAblumList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        //排序  按照最后的修改日期排序
        NSString * stamp1 =  ((NSDictionary *)obj1)[@"creationDate"];
        NSString * stamp2 =  ((NSDictionary *)obj2)[@"creationDate"];
        NSComparisonResult result = [stamp1 compare:stamp2 options:NSCaseInsensitiveSearch];
        return result == NSOrderedAscending; //升序
    }];
    
    return resultArr;
}

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
    return nil;
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
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    
    return assets;
}

#pragma mark - 获取指定相册内的所有图片
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
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

#pragma mark - 获取asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = resizeMode;//控制照片尺寸
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    //option.synchronous = YES;
    option.networkAccessAllowed = YES;
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        completion(image);
    }];
}
@end

