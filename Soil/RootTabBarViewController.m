//
//  RootTabBarViewController.m
//  Soil
//
//  Created by Mike on 27/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "RootTabBarViewController.h"

@interface RootTabBarViewController ()<GADInterstitialDelegate>

@end

@implementation RootTabBarViewController

- (void)presentInterstitialAd {
    if (!self.interstitial) {
        self.interstitial = [[GADInterstitial alloc]
                             initWithAdUnitID:@"ca-app-pub-3940256099942544/1033173712"];
        self.interstitial.delegate = self;
        GADRequest *request = [GADRequest request];
        [self.interstitial loadRequest:request];
    } else {
        if (self.interstitial.hasBeenUsed) {
            self.interstitial = [[GADInterstitial alloc]
                                 initWithAdUnitID:@"ca-app-pub-3940256099942544/1033173712"];
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

/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
    if (self.interstitial.isReady && !self.presentedViewController) {
        [self.interstitial presentFromRootViewController:self];
    }
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
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
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}

@end
