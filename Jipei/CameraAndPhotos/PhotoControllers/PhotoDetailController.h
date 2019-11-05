//
//  PhotoDetailController.h
//  JiPei
//
//  Created by 申屠 on 2017/11/1.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotosLoader.h"

@interface PhotoDetailController : UIViewController

-(instancetype)initWithData:(NSArray *)data andPassImage:(UIImage *)passImage andIndex:(NSInteger)index;

@end

