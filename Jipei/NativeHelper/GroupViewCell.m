//
//  GroupViewCell.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "GroupViewCell.h"
#import <Photos/Photos.h>

@interface GroupViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *count;

@end

@implementation GroupViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    // Initialization code
}

- (void)setModel:(NSDictionary *)model{
    _model = model;
    _title.text = model[@"title"];
    _count.text = [NSString stringWithFormat:@"(%@)",model[@"count"]];
    PHAsset * asset = model[@"headImageAsset"];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 从asset中获得图片
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(50, 50) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        _img.image = result ? result : nil;
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
