#import "DDYTabBarController.h"
#import "DDYNavigationController.h"

@interface DDYTabBarController ()

@end

@implementation DDYTabBarController

DDYNavigationController * myNavigation(NSString *classKey, NSString *title, UIImage *imageN, UIImage *imageS) {
    UIViewController *vc = [NSClassFromString(classKey) new];
    vc.navigationItem.title = NSLocalizedStringFromTable(title, @"DDYLanguageExample", nil);
    vc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:NULL];
    vc.tabBarItem.title = NSLocalizedStringFromTable(title, @"DDYLanguageExample", nil);
    vc.tabBarItem.image = [imageN imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [imageS imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return [[DDYNavigationController alloc] initWithRootViewController:vc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *imgN = [self circleBorderWithColor:[UIColor lightGrayColor] radius:12];
    UIImage *imgS = [self circleImageWithColor:[UIColor blueColor] radius:12];
    [self addChildViewController:myNavigation(@"ViewController", @"DDYTabbar1", imgN, imgS)];
    [self addChildViewController:myNavigation(@"ViewController", @"DDYTabbar2", imgN, imgS)];
    [self addChildViewController:myNavigation(@"ViewController", @"DDYTabbar3", imgN, imgS)];
    [self addChildViewController:myNavigation(@"ViewController", @"DDYTabbar4", imgN, imgS)];
}

#pragma mark 支持旋转的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}
#pragma mark 是否支持自动旋转
- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}
#pragma mark 状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.selectedViewController preferredStatusBarStyle];
}

#pragma mark 绘制圆形图片
- (UIImage *)circleImageWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius*2.0, radius*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillEllipseInRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark 绘制圆形框
- (UIImage *)circleBorderWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius*2.0, radius*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, radius, radius, radius-1, 0, 2*M_PI, 0);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
