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
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation AppDelegate (Config)

- (void)configForShow {
    
    UserDefaults *user = [UserDefaults userDefault];
    
    RootTabBarViewController *root = (RootTabBarViewController *)self.window.rootViewController;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:root.viewControllers];
    
    UIStoryboard *meiziStoryboard = [UIStoryboard storyboardWithName:@"Meizi" bundle:nil];
    UIViewController *meizi = meiziStoryboard.instantiateInitialViewController;
    [arr insertObject:meizi atIndex:1];
    
//    if (user.showBody) {
//        root.viewControllers = arr;
//    }
    
    [self getIPAdress:^(NSString *countryID) {
        if (![countryID isEqualToString:@"US"]) {
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
                    NSLog(@"%@", [NSThread currentThread]);
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
                            if ([dataDic[@"showInterstitial"] integerValue]) {
                                user.showInterstitial = YES;
                            } else {
                                user.showInterstitial = NO;
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
                NSLog(@"%@", [NSThread currentThread]);
                NSLog(@"%@", error);
            }];
        }
    }];
}

- (void)getIPAdress:(void(^)(NSString *countryID))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *ipURL = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
        NSData *data = [NSData dataWithContentsOfURL:ipURL];
        NSDictionary *ipDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSInteger code = [ipDic[@"code"] integerValue];
        if (code==0) {
            NSDictionary *dataDic = ipDic[@"data"];
            NSString *countryID = dataDic[@"country_id"];
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(countryID);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(@"");
            });
        }
    });
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    if (![manager.responseSerializer.acceptableContentTypes containsObject:@"text/plain"]) {
//        NSSet *set = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/plain", @"text/html"]];
//        manager.responseSerializer.acceptableContentTypes = set;
//    }
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//
//    NSString *taobaourl = @"http://ip.chinaz.com/getip.aspx";//[@"http://ip.taobao.com/service/getIpInfo.php?ip=myip" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//
//    NSDictionary *parameters = @{@"ip":@"myip"};
//    [manager GET:taobaourl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@", error);
//    }];
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

@end
