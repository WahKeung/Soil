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

@interface ResultsTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    
    self.pageIndex = 1;
    [self requestDataWithKeyword:self.keyword site:self.site pageIndex:self.pageIndex];
    self.navigationItem.title = [NSString stringWithFormat:@"\"%@\"结果", self.keyword];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = self.navigationItem.title;
    self.navigationItem.backBarButtonItem = backItem;
    
    self.refreshControl.enabled = YES;
    [self.refreshControl beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.showInterstitialAD) {
        [self showInterstitialAd];
        self.showInterstitialAD = NO;
    }
}

- (void)showInterstitialAd {
    if ([self.tabBarController isKindOfClass:[RootTabBarViewController class]]) {
        RootTabBarViewController *rootTabBarController = (RootTabBarViewController *)self.tabBarController;
        [rootTabBarController presentInterstitialAd];
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
        [self showWebControllerWithUrlString:model.url andTitle:model.title];
    }
}

- (void)showWebControllerWithUrlString:(NSString *)urlString andTitle:(NSString *)title {
    
    UIStoryboard *mainStryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *webController = [mainStryboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webController.urlString = urlString;
    webController.title = title;
    [self showViewController:webController sender:nil];
    self.showInterstitialAD = YES;
}

- (void)requestDataWithKeyword:(NSString *)keyword site:(NSString *)site pageIndex:(NSInteger)pageIndex {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    static NSString *urlString = @"http://yikaotuan.cn/public/index.php";
    NSString *value = [NSString stringWithFormat:@"/index/search/index/title/%@/site/%@/page/%zd", keyword, site, pageIndex];
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
            if (idx==4 || idx==9) {
                ResultModel *adModel = [[ResultModel alloc] init];
                adModel.isAD = YES;
                adModel.showInterstitial = YES;
                [self.dataArray addObject:adModel];
            }
        }];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

@end
