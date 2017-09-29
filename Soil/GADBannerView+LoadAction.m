//
//  GADBannerView+LoadAction.m
//  Soil
//
//  Created by Mike on 27/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "GADBannerView+LoadAction.h"

static NSString *const kADUnitID = @"ca-app-pub-3925127038024110/3367115478";
static NSString *const kADUnitIDForTest = @"ca-app-pub-3940256099942544/6300978111";

@implementation GADBannerView (LoadAction)

- (void)loadADWithRootViewController:(UIViewController *)rootViewController {
#ifdef DEBUG
    // Debug 模式的代码...
    self.adUnitID = kADUnitIDForTest;
#else
    // Release 模式的代码...
    self.adUnitID = kADUnitID;
#endif
    self.adSize = kGADAdSizeBanner;
    self.rootViewController = rootViewController;
    GADRequest *request = [GADRequest request];
    [self loadRequest:request];
}

@end
