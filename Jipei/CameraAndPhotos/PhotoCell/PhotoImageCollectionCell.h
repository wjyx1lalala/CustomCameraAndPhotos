//
//  PhotoImageCollectionCell.h
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol PhotoImageCollectionCellClickDelegate <NSObject>

- (void)springAnimatedStart;

- (void)clickImageWithImage:(UIImage *)image andFilePath:(NSString *)filePath andPop:(BOOL)pop andIndex:(NSInteger)index;

- (void)springAnimatedEnd;
@optional
//开始Icloud图片的回调
- (void)startiCloudImageLoading;

- (void)finishiCloudImageLoading;

@end

@interface PhotoImageCollectionCell : UICollectionViewCell

@property (nonatomic,assign)NSInteger index;
@property (nonatomic,strong)PHAsset * asset;
@property (nonatomic,weak) id <PhotoImageCollectionCellClickDelegate> delegate;
@property (nonatomic,assign) BOOL allowiCloudNet;//是否允许使用网络下载icloud图片

@end
