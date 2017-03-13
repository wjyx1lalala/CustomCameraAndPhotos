//
//  LJ_FileTool.h
//  FileDirectoryTool
//
//  Created by nuomi on 2017/2/7.
//  Copyright © 2017年 xgyg. All rights reserved.
//  应用程序文件调试系统

#import <Foundation/Foundation.h>

@interface LJ_FileTool : NSObject


+ (instancetype)sharedTool;

//打开应用目录面板
- (void)openAppDirectoryPanel;

- (void)getFileMD5WithFilePath:(NSString *)filePath
                       success:(void (^)(NSString *fileMD5String))success
                       failure:(void (^)(NSString *errorString))failure;





@end
