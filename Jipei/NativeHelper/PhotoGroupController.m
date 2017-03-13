//
//  PhotoGroupController.m
//  Jipei
//
//  Created by 魏家园潇 on 2017/3/13.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "PhotoGroupController.h"
#import "PhotosLoader.h"
#import "GroupViewCell.h"
#import "PhotosGroupDetailContoller.h"

@interface PhotoGroupController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSMutableArray * dataSource;
@property (nonatomic,strong)UITableView * tableView;
@end

@implementation PhotoGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"照片";
    [self setUpUI];
    [self loadData];
    UIBarButtonItem *backBtnI = [[UIBarButtonItem alloc] initWithTitle:@"重新加载" style:UIBarButtonItemStylePlain target:self action:@selector(loadData)];
//    
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
//                                       
//                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                       
//                                       target:nil action:nil];
//    
//    negativeSpacer.width = -17;
    
    self.navigationItem.leftBarButtonItems = @[backBtnI];
    // Do any additional setup after loading the view.
}

- (void)loadData{
    _dataSource =  [[PhotosLoader sharePhotoTool] getPhotoAblumList];
    [self.tableView reloadData];
}

- (void)setUpUI{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.rowHeight = 58;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"GroupViewCell" bundle:nil] forCellReuseIdentifier:@"GroupViewCell"];
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GroupViewCell"];
    cell.model = _dataSource[indexPath.row];
    return cell;
}

#pragma mark - 点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PhotosGroupDetailContoller * detailVC = [[PhotosGroupDetailContoller alloc] init];
    NSDictionary * dict = _dataSource[indexPath.row];
    PHAsset * asset = dict[@"headImageAsset"];
    PHAssetCollection * collection = dict[@"assetCollection"];
    detailVC.title = dict[@"title"];
    detailVC.collection = collection;
    [self.navigationController pushViewController:detailVC animated:YES];
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
