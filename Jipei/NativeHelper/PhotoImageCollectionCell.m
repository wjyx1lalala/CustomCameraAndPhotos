//
//  PhotoImageCollectionCell.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "PhotoImageCollectionCell.h"

@implementation PhotoImageCollectionCell
static int count = 0;
- (void)awakeFromNib {
    [super awakeFromNib];
    count++;
    NSLog(@"创建了%d个",count);
    // Initialization code
}
- (void)dealloc
{
    count--;
    NSLog(@"销毁后剩余%d个",count);
}

@end
