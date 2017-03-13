//
//  LJ_FileInfo.h
//  FileDirectoryTool
//
//  Created by nuomi on 2017/2/7.
//  Copyright © 2017年 xgyg. All rights reserved.
//  获取文件MD5 用于验证文件完整性
//  手机的内存空间  暂时未实现

#import <Foundation/Foundation.h>

@interface LJ_FileInfo : NSObject

+ (NSString*)getFileMD5WithPath:(NSString*)path;

+ (NSMutableArray*)searchAllFileFromRightDirPath:(NSString *)rightDirPath;

+ (NSString *)judgeFileTypeWithPath:(NSString *)filePath;

@end
