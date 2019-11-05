//
//  PhotosGroupDetailContoller.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//  1.支持使用状态下,图片库发生变化
//  2:前后台进入以后判断图片是否发生了变化
//  3:防止后台以后图库发生了变化

#import "PhotosGroupDetailContoller.h"
#import "PhotoImageCollectionCell.h"
#import "PhotoLibraryController.h"
#import "PhotoDetailController.h"
#import "PhotosLoader.h"
#import "UIImage+clipsImage.h"
#import "HighSpeedImageCache.h"
#import "ImageCropperViewController.h"
#import "ImageTool.h"
static NSString * CellIdentifier = @"PhotoImageCollectionCell";

#define MARGIN 5

#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define SCREEN_W [UIScreen mainScreen].bounds.size.width 
#define MIN_W (SCREEN_W > SCREEN_H ? SCREEN_H : SCREEN_W)
#define ITEM_WIDTH (MIN_W - 2 * MARGIN)/3

@interface PhotosGroupDetailContoller ()<UICollectionViewDelegate,UICollectionViewDataSource,PhotoImageCollectionCellClickDelegate,PHPhotoLibraryChangeObserver,ImageCropperDelegate>

@property (nonatomic,strong)UIActivityIndicatorView * indicatorView;//loading
@property (nonatomic,strong)UICollectionView * collectionView;
@property (nonatomic,strong)NSArray * dataSource;

//查询的集合
@property (nonatomic,strong)PHFetchResult * fetchResult;
@property (nonatomic,strong)PHCachingImageManager * imageManager;
@property (nonatomic,assign)CGRect previousPreheatRect;

@property (nonatomic,copy) NSString * filePath;
@end

@implementation PhotosGroupDetailContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self asyncLoadData:YES];
    self.collectionView.multipleTouchEnabled = NO;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:NO];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoImageCollectionCellAddGesture" object:nil];
}


#pragma mark - 设置UI页面
- (void)setUpUI{
    
    self.title = self.ablumList.title;
    UIBarButtonItem *cancleBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickCancle)];
    self.navigationItem.rightBarButtonItems = @[cancleBtn];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_WIDTH);
    layout.minimumLineSpacing = MARGIN;
    // 设置垂直间距
    layout.minimumInteritemSpacing = MARGIN;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = YES;
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[PhotoImageCollectionCell class] forCellWithReuseIdentifier:CellIdentifier];
    [self.view addSubview:_collectionView];
    //loading加载菊花
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(0, 0, 30, 30);
    _indicatorView.center = self.view.center;
    [self.view addSubview:_indicatorView];
    _indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * centX = [NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint * centY = [NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self.view addConstraints:@[centX,centY]];
    [_indicatorView startAnimating];

}

- (void)clickCancle{
    PhotoLibraryController * nac = (PhotoLibraryController *)self.navigationController;
    nac.callBack = nil;
    [nac dismissViewControllerAnimated:YES completion:nil];
}

// MARK: 图片库发生变化 的代理 可能是在子线程调用
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    PHFetchOptions * fecchOptions = [[PHFetchOptions alloc] init];
    fecchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult * fetchResult = [PHAsset fetchAssetsWithOptions:fecchOptions];
    PHFetchResultChangeDetails * details = [changeInstance changeDetailsForFetchResult:fetchResult];
    fetchResult = details.fetchResultAfterChanges;
    NSLog(@"图片库发生了变化%@",details);
}


#pragma mark - 异步加载数据
- (void)asyncLoadData:(BOOL)needLoadImage{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray * newArr  = [[PhotosLoader sharePhotoTool] getAssetsInAssetCollection:self.ablumList.assetCollection sortByCreaeteDateAscending:NO];
        if ([self.dataSource isEqualToArray:newArr]) {
          //防止后台进入前后以后,刷新数据造成的页面闪屏
          return ;
        }else{
          self.dataSource = newArr;
        }
      
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.dataSource.count == 0){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [_indicatorView stopAnimating];
                //会有白色闪屏
                [self.collectionView reloadData];
            }
        });
    });
}



#pragma mark - cell的代理事件
- (void)startiCloudImageLoading{
    self.collectionView.userInteractionEnabled = NO;
}

- (void)finishiCloudImageLoading{
    self.collectionView.userInteractionEnabled = YES;
}

- (void)springAnimatedStart{
    self.collectionView.userInteractionEnabled = NO;
}

- (void)springAnimatedEnd{
    self.collectionView.userInteractionEnabled = YES;
}

//cell 点击了图片
- (void)clickImageWithImage:(UIImage *)image andFilePath:(NSString *)filePath andPop:(BOOL)pop andIndex:(NSInteger)index{
    //image 判断是否获取到了图片
    if(!image){
        CallBackBlock callBack = ((PhotoLibraryController *)self.navigationController).callBack;
        [self clickCancle];
        callBack(@{@"errorMsg":@"获取图片失败"});
    }else{
        PhotoLibraryController * nac = (PhotoLibraryController *)self.navigationController;
			  self.collectionView.userInteractionEnabled = YES;
        if(nac.allowClips) {
            self.filePath = filePath;
            ImageCropperViewController *imgEditorVC = [[ImageCropperViewController alloc] initWithImage:image];
            imgEditorVC.delegate = self;
            [self.navigationController pushViewController:imgEditorVC animated:YES];
            return;
        }else{
          if(pop){
            //处理好图片压缩,保存的过程
            [ImageTool saveImgToAppWithImage:image complete:^(BOOL isSaveOK, NSDictionary *imageInfo) {
              CallBackBlock callBack = ((PhotoLibraryController *)self.navigationController).callBack;
              if (isSaveOK && callBack) {
                //保存成功,而且有回调
                callBack(imageInfo);
              }else if (!isSaveOK && callBack){
                //保存失败,而且有回调
                callBack(@{@"errorMsg":@"图片保存失败"});
              }
              [self clickCancle];
            }];
          }else{
            //进入大图模式
            PhotoDetailController *pdc = [[PhotoDetailController alloc]initWithData:_dataSource andPassImage:image andIndex:index];
            [self.navigationController pushViewController:pdc animated:YES];
          }
        }
    }
}

#pragma mark - 图片裁剪过以后的回调
- (void)imageCropperDidFinished:(UIImage *)editedImage{
    [ImageTool saveImgToAppWithImage:editedImage complete:^(BOOL isSaveOK, NSDictionary *imageInfo) {
        CallBackBlock callBack = ((PhotoLibraryController *)self.navigationController).callBack;
        if (isSaveOK && callBack) {
            //保存成功,而且有回调
            callBack(imageInfo);
        }else if (!isSaveOK && callBack){
            //保存失败,而且有回调
            callBack(@{@"errorMsg":@"图片保存失败"});
        }
        [self clickCancle];
    }];
}

#pragma mark - collectionView 的代理事件

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoImageCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    PHAsset * asset = _dataSource[indexPath.row];
    cell.index = indexPath.row;
    cell.asset = asset;
    cell.delegate = self;
    cell.allowiCloudNet = ((PhotoLibraryController *)self.navigationController).allowiCloudNet;
    return cell;
}

- (void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
