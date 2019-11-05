//
//  PhotoDetailCollectionCell.h
//  JiPei
//
//  Created by 申屠 on 2017/11/1.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

@interface PhotoDetailCollectionCell : UICollectionViewCell

@property (nonatomic,strong) PHAsset * asset;
@property (nonatomic,strong) UIImageView * imgV;
@property (nonatomic,assign) BOOL fixed;
@property (nonatomic,assign) BOOL allowiCloudNet;

@end

