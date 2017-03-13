//
//  ViewController.m
//  Jipei
//
//  Created by nuomi on 2017/3/10.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "ViewController.h"
#import "PhotoLibraryController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 50, 50);
    btn.backgroundColor  =[UIColor redColor];
    self.view.backgroundColor  =[UIColor whiteColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
}

- (void)click{
    PhotoLibraryController * vc = [PhotoLibraryController create];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
