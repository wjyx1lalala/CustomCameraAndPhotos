//
//  PhotoDetailController.m
//  JiPei
//
//  Created by 申屠 on 2017/11/1.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "PhotoLibraryController.h"
#import "PhotoDetailController.h"
#import "PhotoDetailCollectionCell.h"
#import <Photos/Photos.h>//IOS 8 以后直接使用这个库
#import "PhotosLoader.h"
#import "ImageTool.h"

#define MARGIN_TOP 0
#define MARGIN 0
#define TOOL_H 64
#define BTN_H 35
#define COVER_DURATION 0.5
#define DISSMISS_DURATION 0.3
#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define ITEM_WIDTH SCREEN_W

static NSString *DetailCellIdentifier = @"DetailCellIdentifier";
static NSString * LoadImageOver = @"LoadImageOver";


@interface PhotoDetailController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
	BOOL hasRemove;
}

@property (nonatomic,strong)UICollectionView * collectionView;
@property (nonatomic,strong)UIImageView * coverImgV;
@property (nonatomic,strong)UIImage * passImage;
@property (nonatomic,assign)NSIndexPath * currentIndexPath;
@property (nonatomic,assign)NSInteger passIndex;
@property (nonatomic,copy)NSArray * dataSource;

@end

@implementation PhotoDetailController

- (instancetype)initWithData:(NSArray *)data andPassImage:(UIImage *)passImage andIndex:(NSInteger)index
{
	self = [super init];
  if (self) {
		hasRemove = NO;
		self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.dataSource = data;
    self.passImage = passImage;
    self.passIndex = index>0?index:0;
  }
  return self;
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  [self setUpUI];
	self.automaticallyAdjustsScrollViewInsets = NO;
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeCoverImage) name:LoadImageOver object:nil];
	NSIndexPath *path = [NSIndexPath indexPathForRow:_passIndex inSection:0];
	[self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
  
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:LoadImageOver object:nil];
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)setUpUI{
  UIBarButtonItem *cancleBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickSure)];
  self.navigationItem.rightBarButtonItems = @[cancleBtn];
  
  UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
  layout.itemSize = CGSizeMake(SCREEN_W, SCREEN_H-TOOL_H);
  layout.minimumLineSpacing = MARGIN;
  // 设置垂直间距
  layout.minimumInteritemSpacing = MARGIN;
  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, SCREEN_W, SCREEN_H-TOOL_H) collectionViewLayout:layout];
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.showsHorizontalScrollIndicator = NO;
  _collectionView.delegate = self;
  _collectionView.dataSource = self;
  _collectionView.bounces = YES;
  _collectionView.pagingEnabled = YES;
  [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
  _collectionView.backgroundColor = [UIColor blackColor];
  [_collectionView registerClass:[PhotoDetailCollectionCell class] forCellWithReuseIdentifier:DetailCellIdentifier];
  [self.view addSubview:_collectionView];
	
  // 图片也传递进来，可以代替菊花直接覆盖collectionview，然后数据源好了后移除，使用户感觉不到加载过程
  _coverImgV = [[UIImageView alloc]initWithImage:_passImage];
  _coverImgV.frame = CGRectMake(0, MARGIN_TOP, SCREEN_W, SCREEN_H-TOOL_H);
  _coverImgV.contentMode = UIViewContentModeScaleAspectFit;
  _coverImgV.userInteractionEnabled = NO;
  [self.view addSubview:_coverImgV];
	[self removeCoverImage];
	
	//底部工具栏
	UIView *toolView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_H-TOOL_H, SCREEN_W, TOOL_H)];
	toolView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
	[self.view addSubview:toolView];
	
	UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelBtn.frame = CGRectMake(0, 0, 100, TOOL_H);
	[cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
	[cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
	cancelBtn.backgroundColor = [UIColor clearColor];
	[cancelBtn addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
	[toolView addSubview:cancelBtn];
	
	UIButton * sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_W-120, (TOOL_H-BTN_H)/2, 95, BTN_H)];
	[sureBtn setTitle:@"使用照片" forState:UIControlStateNormal];
	[sureBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[sureBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
	sureBtn.backgroundColor = [UIColor colorWithRed:255.0/255 green:219.0/255 blue:8.0/255 alpha:1.0];
	sureBtn.layer.masksToBounds = YES;
	sureBtn.layer.cornerRadius = BTN_H/2;
	[sureBtn addTarget:self action:@selector(clickSure) forControlEvents:UIControlEventTouchUpInside];
	[toolView addSubview:sureBtn];
	
}

-(void)removeCoverImage{
	if(!hasRemove){
		hasRemove = YES;
		[self.collectionView reloadData];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(COVER_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self.coverImgV removeFromSuperview];
		});
	}
}

-(void)clickSure{
	[self.view setUserInteractionEnabled:NO];
	PhotoLibraryController * nac = (PhotoLibraryController *)self.navigationController;
	PhotoDetailCollectionCell * cell = (PhotoDetailCollectionCell*)[_collectionView cellForItemAtIndexPath:_currentIndexPath];
	UIImage *img = cell.imgV.image;
	//处理好图片压缩,保存的过程
	[ImageTool saveImgToAppWithImage:img complete:^(BOOL isSaveOK, NSDictionary *imageInfo) {
		CallBackBlock callBack = ((PhotoLibraryController *)self.navigationController).callBack;
		if (isSaveOK && callBack) {
			//保存成功,而且有回调
			callBack(imageInfo);
		}else if (!isSaveOK && callBack){
			//保存失败,而且有回调
			callBack(@{@"errorMsg":@"图片保存失败"});
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DISSMISS_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[nac dismissViewControllerAnimated:YES completion:nil];
		});
	}];
}

-(void)clickCancel{
	PhotoLibraryController * nac = (PhotoLibraryController *)self.navigationController;
	[nac popViewControllerAnimated:YES];
}

#pragma mark - collectionView 的代理事件

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return _dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  PhotoDetailCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:DetailCellIdentifier forIndexPath:indexPath];
  if(!cell){
    cell = [[PhotoDetailCollectionCell alloc]initWithFrame:self.view.bounds];
    cell.asset = _dataSource[_passIndex];
  }
  cell.asset = _dataSource[indexPath.row];
  cell.allowiCloudNet = ((PhotoLibraryController *)self.navigationController).allowiCloudNet;
  return cell;
  
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
  PhotoDetailCollectionCell *a = (PhotoDetailCollectionCell*)cell;
  a.fixed = YES;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
	_currentIndexPath = indexPath;
}

- (void)dealloc{
  
  //[[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
}

@end





