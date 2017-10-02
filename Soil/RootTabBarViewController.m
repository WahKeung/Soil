//
//  RootTabBarViewController.m
//  Soil
//
//  Created by Mike on 27/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "RootTabBarViewController.h"
#import "SYPhotoBrowser.h"
#import "UserDefaults.h"

@interface RootTabBarViewController ()<GADInterstitialDelegate>

@property (nonatomic, copy) void (^handler)(void);

@end

@implementation RootTabBarViewController

- (void)presentInterstitialAd {
    UserDefaults *user = [UserDefaults userDefault];
    if (!user.showInterstitial) {
        return;
    }
    
    NSString *unitID = nil;
#ifdef DEBUG
    unitID = @"ca-app-pub-3940256099942544/1033173712";
#else
    unitID = @"ca-app-pub-3940256099942544/4270592515";
#endif
    
    if (!self.interstitial) {
        self.interstitial = [[GADInterstitial alloc]
                             initWithAdUnitID:unitID];
        self.interstitial.delegate = self;
        GADRequest *request = [GADRequest request];
        [self.interstitial loadRequest:request];
    } else {
        if (self.interstitial.hasBeenUsed) {
            self.interstitial = [[GADInterstitial alloc]
                                 initWithAdUnitID:unitID];
            self.interstitial.delegate = self;
            GADRequest *request = [GADRequest request];
            [self.interstitial loadRequest:request];
        } else {
            if (!self.presentedViewController) {
                [self.interstitial presentFromRootViewController:self];
            }
        }
    }
}

- (void)presentInterstitialAdWithCompletionHandler:(void (^)(void))handler {
    if (handler) {
        UserDefaults *user = [UserDefaults userDefault];
        if (user.showInterstitial) {
            self.handler = handler;
            [self presentInterstitialAd];
        } else {
            handler();
        }
    }
}

/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
    if (self.interstitial.isReady && !self.presentedViewController) {
        [self.interstitial presentFromRootViewController:self];
    } else {
        if (self.handler) {
            self.handler();
            self.handler = nil;
        }
    }
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    if (self.handler) {
        self.handler();
        self.handler = nil;
    }
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad {
    if (self.handler) {
        self.handler();
        self.handler = nil;
    }
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
    if (self.handler) {
        self.handler();
        self.handler = nil;
    }
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    NSLog(@"setSelectedIndex");
    [super setSelectedIndex:selectedIndex];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    NSLog(@"setSelectedViewController");
    static NSInteger clickCount = 1;
    if (clickCount==1) {
//        [self presentInterstitialAdWithCompletionHandler:^{
//            [super setSelectedViewController:selectedViewController];
//        }];
        [super setSelectedViewController:selectedViewController];
        [self presentInterstitialAd];
        clickCount=0;
    } else {
        clickCount++;
        [super setSelectedViewController:selectedViewController];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
