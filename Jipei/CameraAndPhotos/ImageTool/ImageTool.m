//
//  ImageTool.m
//  拍照测试
//
//  Created by wjyx on 2017/4/15.
//  Copyright © 2017年 魏家园潇. All rights reserved.
//

#import "ImageTool.h"
#import "UIImage+Compresser.h"
#import "UIImage+clipsImage.h"

#define FILE_CACHE_PATH  @"JPPicCache"

@implementation ImageTool


//        CallBackBlock callBack = nac.callBack;
//        nac.callBack = nil;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            //NSString * base64 = [image transformToToBase64];
//            //      double deltaTime = [[NSDate date] timeIntervalSinceDate:startDate];
//            //      NSLog(@"transformToToBase64 cost time = %f ms", deltaTime *1000.0);
//
//            NSString * locatPath = [self writeImageToCachePath:image andPathName:(NSString *)filePath];
//            //locapath 可能为空
//            CGSize imgSize = image.size;
//            //    NSDictionary * info = @{@"base64":base64 ? base64 : @"",@"filePath":filePath?filePath:@""};
//            if (locatPath) {
//                NSDictionary * info = @{@"filePath":locatPath,@"width":[NSNumber numberWithFloat:imgSize.width],@"height":[NSNumber numberWithFloat:imgSize.height]};
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//                });
//                if (callBack) {
//                    callBack(info);
//                }
//                //图片 处理完以后再进行回调
//            }
//        });


//#pragma mark 图片裁剪后的回调
//- (void)imageCropperDidFinished:(UIImage *)editedImage {
//    NSString * filePath = [self writeImageToCachePath:editedImage andPathName:self.filePath];
//    CGSize imgSize = editedImage.size;
//    NSDictionary * info = @{@"filePath":filePath?filePath:@"",@"width":[NSNumber numberWithFloat:imgSize.width],@"height":[NSNumber numberWithFloat:imgSize.height]};
//    PhotoLibraryController * nac = (PhotoLibraryController *)self.navigationController;
//    CallBackBlock callBack = nac.callBack;
//    if (callBack) {
//        callBack(info);
//    }
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    
//}

//- (NSString *)writeImageToCachePath:(UIImage *)image andPathName:(NSString *)filePath{
//    
//    NSString * fileName = [NSURL fileURLWithPath:filePath].lastPathComponent;
//    fileName = fileName?fileName : @"tmp.JPG";
//    NSString * cachePath = [NSString stringWithFormat:@"%@%@",[NSHomeDirectory() stringByAppendingString:@"/Library/Caches/"],fileName];
//    
//    if ([[NSFileManager defaultManager] isExecutableFileAtPath:cachePath]) {
//        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//    }
//    
//    // 保存图像时,需要使用NSData进行中转,NSData中间可以存储任意格式的二进制数据
//    // 1. 将UIImage转换成NSData
//    NSData *imageData = UIImagePNGRepresentation(image);
//    float size_M = imageData.length /1000.0 /1000.0;
//    if(size_M > 2 ){
//        NSLog(@"图片过大了--%.2fM",size_M);
//    }
//    
//    // 3. 将NSData写入文件
//    BOOL isSuccess = [imageData writeToFile:cachePath atomically:YES];
//    if (isSuccess) {
//        return cachePath;
//    }else{
//        return nil;
//    }
//}

+ (void)clearCache{
    NSString * cacheString = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheString]) {
      return;
    }
    cacheString = [cacheString stringByAppendingPathComponent:FILE_CACHE_PATH];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheString]) {
      return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
      NSFileManager *fileManager = [NSFileManager defaultManager];
      NSArray *contents = [fileManager contentsOfDirectoryAtPath:cacheString error:NULL];
      NSEnumerator *e = [contents objectEnumerator];
      NSString *filename;
      while ((filename = [e nextObject])) {
        [fileManager removeItemAtPath:[cacheString stringByAppendingPathComponent:filename] error:nil];
      }
    });
}

//保存到Cache文件夹里面
+ (void)saveImgToAppWithImage:(UIImage *)image complete:(void(^)(BOOL isSaveOK,NSDictionary * imageInfo))complete{
    if(!image){
        complete(NO,nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      NSDate *startTime = [NSDate date];
        UIImage * newImage = [image fixOrientation];//调整方向
        if(newImage){
          newImage = [newImage compressWithTargetPixel:1200];//任意宽高超过1200，压缩到1200以下分辨率
        }
        //没有判断图片大小，就直接进行压缩，不可取   //压缩300kb以下
        NSData * newImageDate = [self compressionImageBelow2MWithImage:newImage];
        NSDictionary * info_tmp = [self saveImageToAppFileCache:newImageDate];
        NSMutableDictionary * info = [NSMutableDictionary dictionaryWithDictionary:info_tmp?:@{}];
        if(newImage){//读取图片压，缩后的宽高比例
          [info setObject:[NSNumber numberWithFloat:newImage.size.width] forKey:@"width"];
          [info setObject:[NSNumber numberWithFloat:newImage.size.height] forKey:@"height"];
        }
        NSLog(@"图片处理耗时: %f", -[startTime timeIntervalSinceNow]);
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:info];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!info) {
                complete(NO,nil);
            }else{
                complete(YES,dict);
            }
        });
    });
    
}


//获得当前时间
+ (NSString *)getNowDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}



+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}


//获取图片类型
+ (NSString *)iamgeContentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}



#pragma - 保存应用本地的相册
//返回nil 表示存储失败
+ (NSDictionary *)saveImageToAppFileCache:(NSData*)imageData{
    if(!imageData)return nil;
    float size_M = imageData.length /1024.0 /1024.0;
    NSLog(@"压缩后%.3fM",size_M);
    NSString * saveFileName = [NSString stringWithFormat:@"iOSTuboboMerchants%@",[self getNowDate]];
//    NSString * imageType = [self iamgeContentTypeForImageData:imageData]; //获取文件类型
//    if (!([imageType isEqualToString:@"png"] || [imageType isEqualToString:@"jpeg"])) {
//        return nil;
//    }
    NSString * imageType = @"jpeg";
    NSString * cacheString = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheString]) {
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheString withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            return nil;
        }
    }
    cacheString = [cacheString stringByAppendingPathComponent:FILE_CACHE_PATH];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheString]) {
      NSError * error = nil;
      [[NSFileManager defaultManager] createDirectoryAtPath:cacheString withIntermediateDirectories:YES attributes:nil error:&error];
      if (error) {
        return nil;
      }
    }
  
  
    NSString *filePath = [cacheString stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",saveFileName,imageType]];  // 保存文件的名称
    if (!filePath) {
        return nil;
    }
    BOOL result = [imageData writeToFile:filePath atomically:YES];
    if(result){
      NSString * base64 = [imageData base64EncodedStringWithOptions:0];
      NSDictionary * info = @{@"filePath":filePath,@"base64":base64?:@""};
        return info;
    }else{
        return nil;
    }
}



//删除指定文件
+ (void)deleteSpecifiedFileWithPath:(NSString *)filePath{
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL];
    if (isExists) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

//压缩图片到2M以下
+ (NSData *)compressionImageBelow2MWithImage:(UIImage *)image{
  
  NSData *data=UIImageJPEGRepresentation(image, 0.9f);
  CGFloat dataKBytes = data.length/1000.0;
  CGFloat maxQuality = 0.9f;
  if (dataKBytes > 5000) {
    maxQuality = 0.2;
  }else if(dataKBytes > 2000) {
    maxQuality = 0.4;
  }else if(dataKBytes > 1000) {
    maxQuality = 0.5;
  }
  CGFloat lastData = dataKBytes;
  while (dataKBytes > 300 && maxQuality > 0.05) {
    maxQuality = maxQuality - 0.1;
    data = UIImageJPEGRepresentation(image,maxQuality);
    dataKBytes = data.length/1000.0;
    if (lastData == dataKBytes) {
      break;
    }else{
      lastData = dataKBytes;
    }
  }
  return data;
}



#pragma mark - 图片转base64
+ (NSString *)formatImageToBase64String:(UIImage *)image{
    NSData * imageData = UIImageJPEGRepresentation(image, .3);
    NSString * dataString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return dataString;
}

#pragma mark - base64字符串转图片
+ (UIImage *)formatImageFromBase64String:(NSString *)base64String{
    NSData * date = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage * image = [[UIImage alloc] initWithData:date];
    return image;
}



@end
