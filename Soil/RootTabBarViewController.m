//
//  RootTabBarViewController.m
//  Soil
//
//  Created by Mike on 27/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "RootTabBarViewController.h"
#import "SYPhotoBrowser.h"

@interface RootTabBarViewController ()<GADInterstitialDelegate>

@property (nonatomic, strong) SYPhotoBrowser *photoBrowser;
@property (nonatomic, assign) BOOL needToPresentPhotos;

@end

@implementation RootTabBarViewController

- (void)presentInterstitialAd {
    if (!self.interstitial) {
        self.interstitial = [[GADInterstitial alloc]
                             initWithAdUnitID:@"ca-app-pub-3925127038024110/8047051921"];
        self.interstitial.delegate = self;
        GADRequest *request = [GADRequest request];
        [self.interstitial loadRequest:request];
    } else {
        if (self.interstitial.hasBeenUsed) {
            self.interstitial = [[GADInterstitial alloc]
                                 initWithAdUnitID:@"ca-app-pub-3925127038024110/8047051921"];
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
    if (self.needToPresentPhotos && self.photoBrowser) {
        [self presentViewController:self.photoBrowser animated:YES completion:^{
            self.needToPresentPhotos = NO;
            self.photoBrowser = nil;
        }];
    }
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    static NSInteger clickCount = 0;
    if (clickCount==1) {
        [self presentInterstitialAd];
        clickCount=0;
    } else {
        clickCount++;
    }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[SYPhotoBrowser class]] && self.needToPresentPhotos==NO) {
        self.needToPresentPhotos = YES;
        self.photoBrowser = (SYPhotoBrowser *)viewControllerToPresent;
        [self presentInterstitialAd];
    } else {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

@end
