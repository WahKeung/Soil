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

@interface ResultsTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestDataWithKeyword:self.keyword site:self.site pageIndex:1];
    self.navigationItem.title = [NSString stringWithFormat:@"\"%@\"结果", self.keyword];
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
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ResultTableViewCell";
    ResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ResultTableViewCell *resultCell = (ResultTableViewCell *)cell;
    ResultModel *model = self.dataArray[indexPath.row];
    resultCell.titleItemLabel.text = model.title;
    resultCell.descItemLabel.text = model.desc;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ResultModel *model = self.dataArray[indexPath.row];
    [self showWebControllerWithUrlString:model.url andTitle:model.title];
}

- (void)showWebControllerWithUrlString:(NSString *)urlString andTitle:(NSString *)title {
    
    UIStoryboard *mainStryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *webController = [mainStryboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webController.urlString = urlString;
    webController.title = title;
    [self showViewController:webController sender:nil];
}

- (void)requestDataWithKeyword:(NSString *)keyword site:(NSString *)site pageIndex:(NSInteger)pageIndex {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    static NSString *urlString = @"http://yikaotuan.cn/public/index.php";
    NSString *value = [NSString stringWithFormat:@"/index/search/index/title/%@/site/%@/page/%zd", keyword, site, pageIndex];
    NSDictionary *parameters = @{@"s":value};
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = responseObject;
        NSArray *dataArray = responseDictionary[@"data"];
        if (!self.dataArray) {
            self.dataArray = [[NSMutableArray alloc] init];
        }
        for (NSDictionary *itemDictionary in dataArray) {
            ResultModel *model = [[ResultModel alloc] init];
            [model setValuesForKeysWithDictionary:itemDictionary];
            [self.dataArray addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

@end
