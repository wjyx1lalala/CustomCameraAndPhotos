//
//  PhotoGroupController.m
//  Jipei
//
//  Created by nuomi on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//  相册名字,相册数量,相册第一张图片的缩略图

#import "PhotoGroupController.h"
#import "PhotoGroupCell.h"
#import <Photos/Photos.h>//IOS 8 以后直接使用这个库
#import "PhotosLoader.h"
#import "PhotosGroupDetailContoller.h"


static NSString * IDENTIFIER = @"PhotoGroupCell";

@interface PhotoGroupController ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL _enterBackGround;//标识应用是否进入过真正的后台,即Home键
}

@property (nonatomic,strong)UIActivityIndicatorView * indicatorView;
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) UILabel * promptLabel;//权限限制或禁止提示文字

@end

@implementation PhotoGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"照片";
    
    [self setUpUI];
    
    [self judgeAuthorIfDeniedShowAlert:YES];
}

#pragma mark - 判断授权,如果授权是禁止状态,是否自动跳转
- (void)judgeAuthorIfDeniedShowAlert:(BOOL)showAlert{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [_indicatorView startAnimating];
        [self loadDataAndAntoPush:YES];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self judgeAuthorIfDeniedShowAlert:NO];
            });
        }];
    }else if (status == PHAuthorizationStatusDenied) {
//        if (showAlert) {
//            [self showAuthGuideAlert];
//        }
        [self authorizationStatusDenied:YES orUseCustomString:nil];
    }else if (status == PHAuthorizationStatusRestricted){
        [self authorizationStatusDenied:NO orUseCustomString:nil];
    }
}

#pragma mark - 权限禁止后的提示,是否是拒绝,还是权限受限制
- (void)authorizationStatusDenied:(BOOL)isDenied orUseCustomString:(NSString *)string{
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.textColor = [UIColor colorWithRed:.26 green:.26 blue:.26 alpha:1];
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont systemFontOfSize:16];
        _promptLabel.numberOfLines = 0;
    }
    if (string) {
        _promptLabel.text = string;
    }else if (isDenied) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        _promptLabel.text = [NSString stringWithFormat:@"未获得授权访问照片\n请在iPhone的\"设置-隐私-照片\"选项中,允许%@访问您的照片",app_Name];
    }else{
        _promptLabel.text = @"无权限获取照片内容";
    }
    UIFont *font = _promptLabel.font;
    CGSize size = CGSizeMake(280,2000);
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading;
    CGSize labelsize = [_promptLabel.text boundingRectWithSize:size options:opts attributes:attributes context:NULL].size;
    _promptLabel.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    [self.view addSubview:_promptLabel];
    _promptLabel.center = self.view.center;
}


#pragma mark - 跳转权限页面
- (void)showAuthGuideAlert{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString * promapt = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-照片\"选项中,允许%@访问您的照片",app_Name];
  
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未获得授权访问照片"
                                                    message:promapt
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil];
    [alert show];
  
//    NSString * path = UIApplicationOpenSettingsURLString;
//    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:promapt message:nil preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction * gotoAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:path]]) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
//        }
//        [alertVC dismissViewControllerAnimated:YES completion:nil];
//    }];
//    [alertVC addAction:gotoAction];
//    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [self authorizationStatusDenied:YES orUseCustomString:nil];
//    }];
//    [alertVC addAction:cancleAction];
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - 自动跳转
- (void)autoPush{
    if (_dataSource.count > 0) {
        PhotosGroupDetailContoller * detailVC = [[PhotosGroupDetailContoller alloc] init];
        detailVC.ablumList = _dataSource[0];
//      [self.navigationController setViewControllers:@[detailVC] animated:NO];
        [self.navigationController pushViewController:detailVC animated:NO];
    }
}

- (void)clickCancle{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadDataAndAntoPush:(BOOL)autoPush{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        _dataSource =  [[PhotosLoader sharePhotoTool] getPhotoAblumList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_indicatorView stopAnimating];
            if(_promptLabel){
                [_promptLabel removeFromSuperview];
            }
            if(_dataSource.count == 0){
                [self authorizationStatusDenied:NO orUseCustomString:@"没有照片,快去拍照吧~~"];
            }
            [self.tableView reloadData];
            if (autoPush) {
                [self autoPush];
            }
        });
    });
}


- (void)setUpUI{
  
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * image = [UIImage imageNamed:@"photo_return.png"];
    [backButton setImage:image forState:UIControlStateNormal];
    backButton.frame = (CGRect){CGPointZero, image.size};
    [backButton addTarget:self action:@selector(clickCancle) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
  
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.rowHeight = 58;
     [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_tableView registerNib:[UINib nibWithNibName:IDENTIFIER bundle:nil] forCellReuseIdentifier:IDENTIFIER];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
    }
    [self.view addSubview:_tableView];
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(0, 0, 30, 30);
    _indicatorView.center = self.view.center;
    [self.view addSubview:_indicatorView];
    _indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * centX = [NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint * centY = [NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self.view addConstraints:@[centX,centY]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)enterBackground{
    _enterBackGround = YES;
}

- (void)enterActive{
    if (_enterBackGround) {
        [self loadDataAndAntoPush:NO];
    }
    _enterBackGround = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PhotosGroupDetailContoller * detailVC = [[PhotosGroupDetailContoller alloc] init];
    detailVC.ablumList = _dataSource[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoGroupCell * cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    cell.model = _dataSource[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return  cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
