//
//  ImageTool.h
//  拍照测试
//
//  Created by wjyx on 2017/4/15.
//  Copyright © 2017年 魏家园潇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTool : NSObject

//保存到Cache文件夹里面
+ (void)saveImgToAppWithImage:(UIImage *)image complete:(void(^)(BOOL isSaveOK,NSDictionary * imageInfo))complete;


//删除指定文件
+ (void)deleteSpecifiedFileWithPath:(NSString *)filePath;


//删除垃圾缓存
+ (void)clearCache;

@end
