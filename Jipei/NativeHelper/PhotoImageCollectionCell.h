//
//  PhotoImageCollectionCell.h
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoImageCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (nonatomic,strong)PHAsset * asset;
@end
