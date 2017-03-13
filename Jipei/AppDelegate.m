#import "AppDelegate.h"

#import "ImagePickerController.h"
#import "CameraController.h"
#import <ZYSuspensionView/ZYSuspensionView.h>
#import "LJ_FileTool.h"
#import "ViewController.h"
#import "PhotoLibraryController.h"
#import "TopViewAlert.h"

@interface AppDelegate ()<ZYSuspensionViewDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
//    ImagePickerController * vc =  [[ImagePickerController alloc] initWithRootViewController:[[CameraController alloc] init]];
//    vc.navigationBarHidden = YES;
    
    self.window.rootViewController = [ViewController new];
//    self.window.rootViewController = [PhotoLibraryController create];
    //[NativeNavigationController createWithLaunchOptions:launchOptions];
    [self.window makeKeyAndVisible];
    
    
    ZYSuspensionView *sus = [[ZYSuspensionView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 45, [UIScreen mainScreen].bounds.size.height/2, 60, 60) color:[UIColor cyanColor] delegate:self];
    sus.leanType = ZYSuspensionViewLeanTypeEachSide;
    [sus setTitle:@"测试" forState:UIControlStateNormal];
    sus.titleLabel.font = [UIFont systemFontOfSize:16];
    [sus show];
    
    return YES;
}

#pragma mark - 悬浮按钮点击事件
- (void)suspensionViewClick:(ZYSuspensionView *)suspensionView{
    
    [TopViewAlert showWithMessage:@"请在系统相册下载iCloud图片后重试"];
    return;
    [[LJ_FileTool sharedTool] openAppDirectoryPanel];
    
}

@end
