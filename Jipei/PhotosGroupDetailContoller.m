//
//  PhotosGroupDetailContoller.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "PhotosGroupDetailContoller.h"
#import "PhotoImageCollectionCell.h"
#import "PhotosLoader.h"

#define MARGIN 5

#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define SCREEN_W [UIScreen mainScreen].bounds.size.width 
#define MIN_W (SCREEN_W > SCREEN_H ? SCREEN_H : SCREEN_W)
#define ITEM_WIDTH (MIN_W - 2*MARGIN)/3

@interface PhotosGroupDetailContoller ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong)UICollectionView * collectionView;
@property (nonatomic,strong)NSMutableArray * dataSource;

@end

@implementation PhotosGroupDetailContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)setUpUI{
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_WIDTH);
    layout.minimumLineSpacing = MARGIN;
    // 设置垂直间距
    layout.minimumInteritemSpacing = MARGIN;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"PhotoImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoImageCollectionCell"];
    [self.view addSubview:_collectionView];
}

- (void)loadData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataSource = [NSMutableArray array];
        for (PHAsset * asset in [[PhotosLoader sharePhotoTool] getAssetsInAssetCollection:self.collection ascending:NO]) {
            [self.dataSource addObject:asset];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoImageCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoImageCollectionCell" forIndexPath:indexPath];
    PHAsset * asset = _dataSource[indexPath.row];
    if (cell.asset != asset) {
        cell.imgV.image = nil;
    }
    CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    size = CGSizeMake(ITEM_WIDTH, ITEM_WIDTH);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[PhotosLoader sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //指定区域 显示图片
                cell.imgV.image = image;
            });
        }];
    });
    cell.asset = asset;
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
