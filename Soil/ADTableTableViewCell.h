//
//  ADTableTableViewCell.h
//  Soil
//
//  Created by Mike on 27/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;

@interface ADTableTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet GADNativeExpressAdView *nativeExpressAdView;

@end
