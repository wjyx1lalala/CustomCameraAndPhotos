//
//  LJ_FileInfoController.m
//  LJHotUpdate
//
//  Created by nuomi on 2017/2/9.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "LJ_FileInfoController.h"
#import "LJ_FileInfo.h"

@interface LJ_FileInfoController ()

@property (nonatomic,strong) UIWebView * webView;
@property (nonatomic,strong) UIScrollView * scrollView;
@property (nonatomic,copy) NSString * md5;

@end

@implementation LJ_FileInfoController

+ (instancetype)createWithFileName:(NSString *)fileName andFilePath:(NSString *)filePath andFileInfo:(NSDictionary *)fileInfo{
    LJ_FileInfoController * infoVC = [[LJ_FileInfoController alloc] init];
    infoVC.filePath = filePath;
    infoVC.fileName = fileName;
    infoVC.fileInfo = fileInfo;
    return infoVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
}

- (void)setUpUI{
    
    self.title = self.fileName;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(getMD5)];
    self.navigationItem.rightBarButtonItem = right;
    
    NSString * type= [[self.fileName componentsSeparatedByString:@"."] lastObject];
    if ([type isEqualToString:@"json"] || [type isEqualToString:@"html"] || [type isEqualToString:@"js"] || [type isEqualToString:@"pdf"] || [type isEqualToString:@"docx"] || [type isEqualToString:@"xlsx"] || [type isEqualToString:@"ppt"]) {
        //go webView  json js html
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.filePath]];
        [self.webView loadRequest:request];
        [self.scrollView addSubview:self.webView];
        
        [self addFileInfoWithGap];
        
    }else if ([type isEqualToString:@"plist"] || [type isEqualToString:@"jsbundle"] || [type isEqualToString:@"log"]) {
        //go textView  jsbundle plist
        NSString * string = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
        UITextView * tView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 200)];
        tView.text = string;
        tView.editable = NO;
        [self.scrollView addSubview:tView];
        
        [self addFileInfoWithGap];
        
    }else if ([self.fileInfo[@"FileType"] hasPrefix:@"image"]){
        //go imageView
        UIImage * image = [[UIImage alloc] initWithContentsOfFile:self.filePath];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 50;
        CGFloat height = width * image.size.height / image.size.width;
        if (width > image.size.width) {
            imageView.frame = CGRectMake( ([UIScreen mainScreen].bounds.size.width - image.size.width) /2,20,image.size.width, image.size.height);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.scrollView addSubview:imageView];
            [self addFileInfoAndHeight:image.size.height + 10];
        }else{
            imageView.frame = CGRectMake(25, 20,width, height);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.scrollView addSubview:imageView];
            [self addFileInfoAndHeight:height + 10];
        }
    }else{
        //other file
        [self addFileInfoAndHeight:40];
    }
}

- (void)addFileInfoWithGap{
    UILabel * gapLineView = [[UILabel alloc] initWithFrame:CGRectMake(0,  [UIScreen mainScreen].bounds.size.height - 200, [UIScreen mainScreen].bounds.size.width, 20)];
    gapLineView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    gapLineView.text = @"文件信息";
    gapLineView.font = [UIFont systemFontOfSize:14];
    gapLineView.textColor = [UIColor colorWithRed:0.356 green:0.356 blue:0.356 alpha:1];
    gapLineView.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:gapLineView];
    self.scrollView.bounces = NO;
    [self addFileInfoAndHeight:[UIScreen mainScreen].bounds.size.height - 200];
}

- (void)addFileInfoAndHeight:(CGFloat)height{
    NSString * fileSize, *fileModDate,*fileCreateDate, *fileMD5 = @"";
    //文件大小
    fileSize = [self.fileInfo objectForKey:NSFileSize];
    CGFloat kb = [fileSize floatValue]/1024;
    if (kb < 1024) {
        fileSize = [NSString stringWithFormat:@"%.2f%@",kb,@"kb"];
    }else{
        fileSize = [NSString stringWithFormat:@"%.2f%@",kb/1024,@"M"];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //文件创建日期
    fileCreateDate = [dateFormatter stringFromDate:self.fileInfo[NSFileCreationDate]];
    //文件修改日期
    fileModDate =  [dateFormatter stringFromDate:self.fileInfo[NSFileModificationDate]];
    //md5
    fileMD5 = [LJ_FileInfo getFileMD5WithPath:self.filePath];
    self.md5 = fileMD5;
    NSArray * infoArr = @[fileMD5?:@"",fileSize?:@"",fileCreateDate?:@"",fileModDate?:@""];
    NSArray * infoKeyArr = @[@"MD5值：",@"文件大小：",@"创建时间：",@"修改时间："];
    for (int i = 0; i < infoKeyArr.count; i++) {
        UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(10, height + 20, [UIScreen mainScreen].bounds.size.width - 20, 35)];
        backView.clipsToBounds = YES;
        [self.scrollView addSubview:backView];
        
        UILabel * desclb = [self createInfoLabelWithDesc:infoKeyArr[i]];
        desclb.textAlignment = NSTextAlignmentRight;
        desclb.textColor = [UIColor lightGrayColor];
        desclb.frame = CGRectMake(0, 0, 74, 35);
        [backView addSubview:desclb];
        
        UILabel * contentlb = [self createInfoLabelWithDesc:infoArr[i]];
        contentlb.textAlignment = NSTextAlignmentLeft;
        contentlb.textColor = [UIColor blackColor];
        contentlb.frame = CGRectMake(74, 0, [UIScreen mainScreen].bounds.size.width - 94 , 35);
        [backView addSubview:contentlb];
        
        height += 40;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, height + 30);
}

- (void)getMD5{
    [UIPasteboard generalPasteboard].string = self.md5;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"文件MD5复制成功" message:self.md5 preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (UILabel *)createInfoLabelWithDesc:(NSString * )descStr{
    UILabel * label = [[UILabel alloc] init];
    label.text = descStr;
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentRight;
    return label;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 200)];
    }
    return _webView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
