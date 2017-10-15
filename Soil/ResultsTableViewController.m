//
//  ResultsTableViewController.m
//  Soil
//
//  Created by Mike on 19/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "ResultsTableViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "ResultModel.h"
#import "ResultTableViewCell.h"
#import "WebViewController.h"
#import "ADTableTableViewCell.h"
#import "GADNativeExpressAdView+LoadAction.h"
#import "RootTabBarViewController.h"
#import "GADBannerView+LoadAction.h"
#import "UserDefaults.h"
#import "RootTabBarViewController.h"

@interface ResultsTableViewController ()<GADBannerViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) BOOL hasShowRate;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, assign) BOOL didReceiveAd;

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageIndex = 1;
    [self requestDataWithKeyword:self.keyword site:self.site pageIndex:self.pageIndex];
    self.navigationItem.title = [NSString stringWithFormat:@"\"%@\"结果", self.keyword];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = self.navigationItem.title;
    self.navigationItem.backBarButtonItem = backItem;
    
    self.refreshControl.enabled = YES;
    [self.refreshControl beginRefreshing];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"footer"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UserDefaults *user = [UserDefaults userDefault];
    if (user.showRate && !user.clickOnRate) { // && !user.hasShowRate
        [self showRate];
        user.hasShowRate = YES;
    } else {
        if (self.showInterstitialAD) {
            [self showInterstitialAd];
            self.showInterstitialAD = NO;
        }
    }
}

- (void)showRate {
    
    if (self.hasShowRate) {
        return;
    }
    self.hasShowRate = YES;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"好评解锁资源" message:@"撸友们，5星好评带有“福利”字眼，将会有更多的资源和惊喜等着你！机会仅此一次！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"残忍拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self showInterstitialAd];
        self.showInterstitialAD = NO;
    }];
    UIAlertAction *openAppStoreAction = [UIAlertAction actionWithTitle:@"好评赞赏👍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToAppStore];
        UserDefaults *user = [UserDefaults userDefault];
        user.clickOnRate = YES;
        
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        RootTabBarViewController *root = (RootTabBarViewController *)window.rootViewController;
        NSMutableArray *arr = [NSMutableArray arrayWithArray:root.viewControllers];
        
        UIStoryboard *meiziStoryboard = [UIStoryboard storyboardWithName:@"Meizi" bundle:nil];
        UIViewController *meizi = meiziStoryboard.instantiateInitialViewController;
        if (arr.count==2) {
            [arr insertObject:meizi atIndex:1];
            root.viewControllers = arr;
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:openAppStoreAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showInterstitialAd {
    if ([self.tabBarController isKindOfClass:[RootTabBarViewController class]]) {
        RootTabBarViewController *root = (RootTabBarViewController *)self.tabBarController;
        [root presentInterstitialAdFirstIfReadyWithCompletionHandler:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray && self.dataArray.count==0) {
        return 1;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray && self.dataArray.count==0) {
        return [tableView dequeueReusableCellWithIdentifier:@"noResults" forIndexPath:indexPath];
    }
    
    ResultModel *model = self.dataArray[indexPath.row];
    if (model.isAD) {
        ADTableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ADTableTableViewCell" forIndexPath:indexPath];
        return cell;
    } else {
        ResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultTableViewCell" forIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray && self.dataArray.count==0) {
        return;
    }
    
    ResultModel *model = self.dataArray[indexPath.row];
    if (model.isAD) {
        ADTableTableViewCell *adCell = (ADTableTableViewCell *)cell;
        [adCell.nativeExpressAdView loadADWithRootViewController:self];
    } else {
        ResultTableViewCell *resultCell = (ResultTableViewCell *)cell;
        ResultModel *model = self.dataArray[indexPath.row];
        resultCell.titleItemLabel.text = model.title;
        resultCell.descItemLabel.text = model.desc;
        
        if (indexPath.row%20==0 && indexPath.row!=0 && model.showInterstitial) {
            model.showInterstitial = NO;
            [self showInterstitialAd];
        }
    }
    
    if (indexPath.row==self.dataArray.count-1) {
        if (self.dataArray.count/12<=self.pageIndex && self.dataArray.count%12==0) {
            self.pageIndex = self.pageIndex+1;
            [self requestDataWithKeyword:self.keyword site:self.site pageIndex:self.pageIndex];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray && self.dataArray.count==0) {
        return 200;
    }
    
    ResultModel *model = self.dataArray[indexPath.row];
    if (model.isAD) {
        return 100;
    } else {
        return 108;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ResultModel *model = self.dataArray[indexPath.row];
    if (!model.isAD) {
        ResultModel *model = self.dataArray[indexPath.row];
        RootTabBarViewController *root = (RootTabBarViewController *)self.tabBarController;
        [root presentInterstitialAdFirstIfReadyWithCompletionHandler:^{
            [self showWebControllerWithUrlString:model.url andTitle:model.title];
        }];
    }
}

- (void)showWebControllerWithUrlString:(NSString *)urlString andTitle:(NSString *)title {
    
    UIStoryboard *mainStryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *webController = [mainStryboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webController.urlString = urlString;
    webController.title = title;
    webController.showInterstialAD = YES;
    [self showViewController:webController sender:nil];
    self.showInterstitialAD = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.didReceiveAd?66:CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
    view.backgroundColor = [UIColor clearColor];
    view.contentView.backgroundColor = [UIColor clearColor];
    
    if (![view viewWithTag:100]) {
        GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        self.bannerView = bannerView;
        self.bannerView.delegate = self;
        bannerView.tag = 100;
        [view addSubview:bannerView];
        bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bannerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:bannerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [bannerView loadADWithRootViewController:self];
    } else {
//        GADBannerView *bannerView = [view viewWithTag:100];
//        [bannerView loadADWithRootViewController:self];
    }
    
    return view;
}

- (void)requestDataWithKeyword:(NSString *)keyword site:(NSString *)site pageIndex:(NSInteger)pageIndex {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    static NSString *urlString = @"http://yikaotuan.cn/index.php";
    NSString *value = [NSString stringWithFormat:@"/index/search/index/site/%@/title/%@/page/%zd", site, keyword, pageIndex];
    NSDictionary *parameters = @{@"s":value};
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.refreshControl endRefreshing];
        
        NSDictionary *responseDictionary = responseObject;
        NSArray<NSDictionary *> *dataArray = responseDictionary[@"data"];
        if (!self.dataArray) {
            self.dataArray = [[NSMutableArray alloc] init];
        }
        [dataArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ResultModel *model = [[ResultModel alloc] init];
            [model setValuesForKeysWithDictionary:obj];
            model.isAD = NO;
            model.showInterstitial = YES;
            [self.dataArray addObject:model];
//            if (idx==4 || idx==9) {
//                ResultModel *adModel = [[ResultModel alloc] init];
//                adModel.isAD = YES;
//                adModel.showInterstitial = YES;
//                [self.dataArray addObject:adModel];
//            }
        }];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark -

- (void)jumpToAppStore {
    UIApplication *app = [UIApplication sharedApplication];
    NSString *appID = @"1287143610";
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", appID];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
}

#pragma mark -

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    self.didReceiveAd = YES;
    [self.tableView reloadData];
}

@end
