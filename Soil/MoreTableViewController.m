//
//  MoreTableViewController.m
//  Soil
//
//  Created by Mike on 20/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MoreTableViewController.h"
@import GoogleMobileAds;
#import "AppDelegate.h"
#import "KeywordEntity+CoreDataClass.h"

@interface MoreTableViewController ()
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
#ifdef DEBUG
    // Debug 模式的代码...
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/6300978111";
#else
    // Release 模式的代码...
    self.bannerView.adUnitID = @"ca-app-pub-3925127038024110/3367115478";
#endif
    self.bannerView.adSize = kGADAdSizeBanner;
    self.bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[@"655075e7bea6a2c0298f220f9fa5879faaa67139"];
    [self.bannerView loadRequest:request];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 && indexPath.row==0) {
        [self deleteAllHistory];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)deleteAllHistory {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *viewContext = delegate.persistentContainer.viewContext;
    NSFetchRequest *request = [KeywordEntity fetchRequest];
    NSArray<KeywordEntity *> *results = [viewContext executeFetchRequest:request error:nil];
    [results enumerateObjectsUsingBlock:^(KeywordEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [viewContext deleteObject:obj];
    }];
    [delegate saveContext];
}

@end
