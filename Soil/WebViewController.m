//
//  WebViewController.m
//  Soil
//
//  Created by Mike on 17/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
@import GoogleMobileAds;
#import "GADBannerView+LoadAction.h"
#import "ResultsTableViewController.h"
#import "RootTabBarViewController.h"

@interface WebViewController ()

@property (nonatomic, strong) WKWebView *webView;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

@implementation WebViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.bannerView loadADWithRootViewController:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.tabBarController isKindOfClass:[RootTabBarViewController class]] && self.showInterstialAD) {
        self.showInterstialAD = NO;
        RootTabBarViewController *tabBarController = (RootTabBarViewController *)self.tabBarController;
        [tabBarController presentInterstitialAd];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutAction];
    [self.view bringSubviewToFront:self.bannerView];
    
    if (self.urlString.length>0) {
        NSURL *url = [NSURL URLWithString:self.urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];[self.webView loadRequest:request];
    } else {
        self.navigationItem.title = @"免责声明";
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Declaration" ofType:@"html"];
        NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
}

- (void)layoutAction {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    
    [self.view addSubview:webView];
    self.webView = webView;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"webView":webView};
    NSArray *constraitsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views];
    NSArray *constraitsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views];
    [self.view addConstraints:constraitsH];
    [self.view addConstraints:constraitsV];
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 66, 0);
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 66, 0);
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
