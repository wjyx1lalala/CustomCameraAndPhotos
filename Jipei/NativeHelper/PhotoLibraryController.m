//
//  PhotoLibraryController.m
//  JiPei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "PhotoLibraryController.h"
#import "PhotoGroupController.h"

@interface PhotoLibraryController ()

@end

@implementation PhotoLibraryController

+ (instancetype)create{
    PhotoGroupController * rootVC = [[PhotoGroupController alloc] init];
    PhotoLibraryController * vc = [[PhotoLibraryController alloc] initWithRootViewController:rootVC];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
