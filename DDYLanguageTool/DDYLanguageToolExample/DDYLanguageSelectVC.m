#import "DDYLanguageSelectVC.h"
#import "AppDelegate.h"
#import "DDYTabBarController.h"
#import "DDYNavigationController.h"
#import "DDYLanguageTool.h"

@interface DDYLanguageSelectVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DDYLanguageSelectVC

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:@[@{@"title":@"简体中文", @"tag":@"zh-Hans"},
                                                      @{@"title":@"English", @"tag":@"en"},
                                                      @{@"title":@"DDYSystemLanguage", @"tag":@""}]];
    }
    return _dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"DDYSelectLanguage", @"DDYLanguageExample", nil)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ddyCellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ddyCellID"];
    }
    cell.textLabel.text = NSLocalizedStringFromTable(self.dataArray[indexPath.row][@"title"], @"DDYLanguageExample", nil) ;
    NSString *tempTag = self.dataArray[indexPath.row][@"tag"];
    cell.accessoryType = [tempTag isEqualToString:([DDYLanguageTool ddy_AppLanguage]?:@"")] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger index = self.tabBarController.selectedIndex;
    __weak __typeof__ (self)weakSelf = self;
    [DDYLanguageTool ddy_SetLanguage:self.dataArray[indexPath.row][@"tag"] complete:^(NSError *error) {
        __strong __typeof__ (weakSelf)strongSelf = weakSelf;
        [strongSelf resetRootViewController:index];
    }];
}

#pragma mark 重新设置
- (void)resetRootViewController:(NSUInteger)selectedIndex {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    DDYTabBarController *tabBarController = [[DDYTabBarController alloc] init];
    appDelegate.window.rootViewController = tabBarController;
    // 第一层 切换到原来选择的
    tabBarController.selectedIndex = selectedIndex;
    
    if ([tabBarController.selectedViewController isKindOfClass:[DDYNavigationController class]]) {
        DDYNavigationController *navigationController = (DDYNavigationController *)tabBarController.selectedViewController;
        
        // 第二层 重新模态弹出语言选择界面 如果有多层则顺序无动画push
        DDYLanguageSelectVC *languageVC = [[DDYLanguageSelectVC alloc] init];
        [navigationController pushViewController:languageVC animated:NO];
    }
    
}

@end
