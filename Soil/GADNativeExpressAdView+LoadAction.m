//
//  GADNativeExpressAdView+LoadAction.m
//  Soil
//
//  Created by Mike on 27/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "GADNativeExpressAdView+LoadAction.h"

@implementation GADNativeExpressAdView (LoadAction)

- (void)loadADWithRootViewController:(UIViewController *)rootViewController {
#ifdef DEBUG
    self.adUnitID = @"ca-app-pub-3940256099942544/4270592515";
#else
    self.adUnitID = @"ca-app-pub-3925127038024110/7578134287";
#endif
    self.rootViewController = rootViewController;
    GADRequest *request = [GADRequest request];
    [self loadRequest:request];
}

@end
