//
//  ResultsTableViewController.h
//  Soil
//
//  Created by Mike on 19/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsTableViewController : UITableViewController

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, assign) BOOL showInterstitialAD;

@end
