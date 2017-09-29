//
//  AppDelegate+Config.m
//  Soil
//
//  Created by Mike on 29/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "AppDelegate+Config.h"
#import "UserDefaults.h"
#import "RootTabBarViewController.h"

@implementation AppDelegate (Config)

- (void)configForShow {
    
    UserDefaults *user = [UserDefaults userDefault];
    
    RootTabBarViewController *root = (RootTabBarViewController *)self.window.rootViewController;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:root.viewControllers];
    
    UIStoryboard *meiziStoryboard = [UIStoryboard storyboardWithName:@"Meizi" bundle:nil];
    UIViewController *meizi = meiziStoryboard.instantiateInitialViewController;
    [arr insertObject:meizi atIndex:1];
    
    if (user.showBody) {
        root.viewControllers = arr;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    static NSString *urlString = @"http://yikaotuan.cn/";
    NSString *bundleIdentifier = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleIdentifier"];
    NSString *value = [NSString stringWithFormat:@"/index/search/getStatus/code/%@/", bundleIdentifier];
    NSDictionary *parameters = @{@"s":value};
    
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = responseObject;
            if ([resultDic.allKeys containsObject:@"data"]) {
                if ([resultDic[@"data"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDic = resultDic[@"data"];
                    
                    if ([dataDic[@"showBody"] integerValue]) {
                        user.showBody = YES;
                    } else {
                        user.showBody = NO;
                    }
                    if ([dataDic[@"showRate"] integerValue]) {
                        user.showRate = YES;
                    } else {
                        user.showRate = NO;
                    }
                }
            }
        }
        
        if (user.showBody) {
            root.viewControllers = arr;
        } else {
            UITabBarController *root = (UITabBarController *)self.window.rootViewController;
            NSMutableArray *arr = [NSMutableArray arrayWithArray:root.viewControllers];
            if (arr.count>2) {
                [arr removeObjectAtIndex:1];
            }
            root.viewControllers = arr;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

@end
