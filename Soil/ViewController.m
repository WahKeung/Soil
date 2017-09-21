//
//  ViewController.m
//  Soil
//
//  Created by Mike on 17/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "ViewController.h"
@import GoogleMobileAds;
#import "HistoryCollectionViewCell.h"
#import "KeywordEntity+CoreDataClass.h"
#import "AppDelegate.h"

@interface ViewController () <UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *cloudImageView;
@property (weak, nonatomic) IBOutlet UIButton *siteButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSString *selectedSite;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (nonatomic, strong) NSArray<KeywordEntity *> *historyArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
[self readKeywords];
    
    // Replace this ad unit ID with your own ad unit ID.
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
    
    self.selectedSite = @"pan.baidu.com";
    [self setupSubviews];
    [self addObserverForKeyboardWithSelector:@selector(keyboardWillChangeFrameWithNotification:)];
}

- (void)setupSubviews {
    self.searchButton.layer.cornerRadius = 4;
    self.searchButton.layer.masksToBounds = YES;
}

- (void)addObserverForKeyboardWithSelector:(SEL)aSelector {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aSelector name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeObserverForKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillChangeFrameWithNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    /*
     {
     UIKeyboardAnimationCurveUserInfoKey = 7;
     UIKeyboardAnimationDurationUserInfoKey = "0.25";
     UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {320, 253}}";
     UIKeyboardCenterBeginUserInfoKey = "NSPoint: {160, 694.5}";
     UIKeyboardCenterEndUserInfoKey = "NSPoint: {160, 441.5}";
     UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 568}, {320, 253}}";
     UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 315}, {320, 253}}";
     UIKeyboardIsLocalUserInfoKey = 1;
     }
     */
    CGFloat animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frameBegin = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frameEnd = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectGetMinY(frameEnd)<CGRectGetHeight([UIScreen mainScreen].bounds) && CGRectGetMinY(frameBegin)>=CGRectGetHeight([UIScreen mainScreen].bounds)) {
        [self activateSearchBarWithDuration:animationDuration];
    } else if (CGRectGetMinY(frameEnd)==CGRectGetHeight([UIScreen mainScreen].bounds)) {
        [self unactivateSearchBarWithDuration:animationDuration];
    }
    
}

- (void)activateSearchBarWithDuration:(CGFloat)duration {
    CGRect textFieldFrameOnView = [self.textField.superview convertRect:self.textField.frame toView:self.view];
    CGFloat minY = CGRectGetMinY(textFieldFrameOnView);
    CGFloat height = CGRectGetHeight(textFieldFrameOnView);
    CGFloat top = (44-height)/2;
    CGFloat diff = minY-top;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.stackView.transform = CGAffineTransformMakeTranslation(0, -diff+64);
        self.cloudImageView.transform = CGAffineTransformMakeTranslation(0, -diff);
        [self.view layoutIfNeeded];
    }];
}

- (void)unactivateSearchBarWithDuration:(CGFloat)duration {
    [UIView animateWithDuration:0.25 animations:^{
        self.stackView.transform = CGAffineTransformIdentity;
        self.cloudImageView.transform = CGAffineTransformIdentity;
        [self.view layoutIfNeeded];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
}


- (void)dealloc {
    [self removeObserverForKeyboard];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchAction:(id)sender {
    [self performSegueWithIdentifier:@"segue.show.ResultsTableViewController" sender:nil];
    [self insertKeyword:self.textField.text];
}
- (IBAction)changeSiteAction:(id)sender {
    NSDictionary *sites = @{@"百度网盘":@"pan.baidu.com",
                            @"115网盘":@"115.com",
                            @"微盘":@"vdisk.weibo.com"};
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择网盘" message:@"请选择你需要的网盘" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [sites enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *title = [NSString stringWithFormat:@"%@（%@）", key, obj];
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedSite = obj;
            [self.siteButton setTitle:title forState:UIControlStateNormal];
        }];
        [alertController addAction:action];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)changeSourceAction:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"搜索源" message:@"请选择你需要的搜索源" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *item0Action = [UIAlertAction actionWithTitle:@"地址一（bing）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"地址一（bing）");
    }];
    for (UIAlertAction *action in @[item0Action, cancelAction]) {
        [alertController addAction:action];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self performSegueWithIdentifier:@"segue.show.ResultsTableViewController" sender:nil];
    [self insertKeyword:self.textField.text];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.show.ResultsTableViewController"]) {
        UIViewController *destinationController = segue.destinationViewController;
        [destinationController setValue:sender?sender:self.textField.text forKey:@"keyword"];
        [destinationController setValue:self.selectedSite forKey:@"site"];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.textField resignFirstResponder];
    KeywordEntity *entity = self.historyArray[indexPath.item];
    [self performSegueWithIdentifier:@"segue.show.ResultsTableViewController" sender:entity.value];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.historyArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionview.cell" forIndexPath:indexPath];
    NSString *title = self.historyArray[indexPath.item].value;
    cell.itemTitleLabel.text = title;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.historyArray[indexPath.item].value;
    CGSize size = [title boundingRectWithSize:CGSizeMake(collectionView.bounds.size.width, 30) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    return CGSizeMake(size.width+8, 30);
}

#pragma mark - core data

- (void)insertKeyword:(NSString *)keyword {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *viewContext = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *request = [KeywordEntity fetchRequest];
    NSArray<KeywordEntity *> *results = [viewContext executeFetchRequest:request error:nil];
    if (results.count<1) {
        KeywordEntity *keywordEntity = [NSEntityDescription insertNewObjectForEntityForName:@"KeywordEntity" inManagedObjectContext:viewContext];
        keywordEntity.value = keyword;
        [appDelegate saveContext];
        [self readKeywords];
    } else {
        
        for (KeywordEntity *entity in results) {
            if ([keyword isEqualToString:entity.value]) {
                return ;
            }
        }
        KeywordEntity *keywordEntity = [NSEntityDescription insertNewObjectForEntityForName:@"KeywordEntity" inManagedObjectContext:viewContext];
        keywordEntity.value = keyword;
        [appDelegate saveContext];
        [self readKeywords];
    }
}

- (void)readKeywords {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *viewContext = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *request = [KeywordEntity fetchRequest];
    NSArray *results = [viewContext executeFetchRequest:request error:nil];
    self.historyArray = [results reverseObjectEnumerator].allObjects;
    for (KeywordEntity *entity in self.historyArray) {
        NSLog(@"%@", entity.value);
    }
    [self.collectionView reloadData];
}

- (void)deleteAllKeywords {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *viewContext = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *request = [KeywordEntity fetchRequest];
    NSArray<KeywordEntity *> *results = [viewContext executeFetchRequest:request error:nil];
    [results enumerateObjectsUsingBlock:^(KeywordEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [viewContext deleteObject:obj];
    }];
    [appDelegate saveContext];
    [self readKeywords];
}

@end
