//
//  LJ_FileTool.m
//  FileDirectoryTool
//
//  Created by nuomi on 2017/2/7.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LJ_FileTool.h"
#import "LJ_FileInfo.h"
#import "LJ_DirToolNavigatorController.h"

@interface LJ_FileTool ()

@property (nonatomic,strong)LJ_DirToolNavigatorController * navVC;

@end

@implementation LJ_FileTool

static LJ_FileTool *_singleton;

+ (instancetype)sharedTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[self alloc] init];;
    });
    return _singleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [super allocWithZone:zone];
    });
    return _singleton;
}

#pragma mark 打开应用目录面板
- (void)openAppDirectoryPanel{
    if (_navVC) {
        UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if(root.presentedViewController) {
            [root.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }else{
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_navVC animated:YES completion:nil];
        }
    }else{
        LJ_DirToolNavigatorController * vc = [LJ_DirToolNavigatorController create];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
        _navVC = vc;
    }
}

#pragma mark 获取文件的MD5
- (void)getFileMD5WithFilePath:(NSString *)filePath
                       success:(void (^)(NSString *fileMD5String))success
                       failure:(void (^)(NSString *errorString))failure{
    if (!filePath) {
        NSString * errorString = [NSString stringWithFormat:@"\n%@%@%@",@"filePath:",filePath,@"\nWarn: filePath cannot be nil, please checkout~"];
        failure(errorString);
        return;
    }else if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO){
        NSString * errorString = [NSString stringWithFormat:@"\n%@%@%@",@"filePath:",filePath,@"\nWarn: file not exist,please checkout you filePath has exist in your application~"];
        failure(errorString);
        return;
    }
    
    NSString * fileMD5String = [LJ_FileInfo getFileMD5WithPath:filePath];
    if (fileMD5String) {
        success(fileMD5String);
    }else{
        NSString * errorString = [NSString stringWithFormat:@"\n%@%@%@",@"file:",filePath,@"\nWarn: file get MD5 failure~"];
        failure(errorString);
    }
}

@end
