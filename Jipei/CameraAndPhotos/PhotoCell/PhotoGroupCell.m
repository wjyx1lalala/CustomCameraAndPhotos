//
//  PhotoGroupCell.m
//  Jipei
//
//  Created by nuomi on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "PhotoGroupCell.h"
#import "PhotosLoader.h"

@interface PhotoGroupCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *count;

@end

@implementation PhotoGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setModel:(JPAblumList *)model{
    _model = model;
    _title.text = model.title;
    _count.text = [NSString stringWithFormat:@"(%@)",model.count];
    PHAsset * asset = model.headImageAsset;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 从asset中获得图片
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(50, 50) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        _imgV.image = result ? result : nil;
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
