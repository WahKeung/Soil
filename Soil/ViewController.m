//
//  ViewController.m
//  Soil
//
//  Created by Mike on 17/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *cloudImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    NSLog(@"%@", info);
    CGFloat animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frameBegin = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frameEnd = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat heightDiff = CGRectGetMinY(frameEnd)-CGRectGetMinY(frameBegin);
    
    if (heightDiff<0) {
        [self activateSearchBar];
    } else {
        [self unactivateSearchBar];
    }
    
}

- (void)activateSearchBar {
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

- (void)unactivateSearchBar {
    [UIView animateWithDuration:0.25 animations:^{
        self.stackView.transform = CGAffineTransformIdentity;
        self.cloudImageView.transform = CGAffineTransformIdentity;
        [self.view layoutIfNeeded];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
    
}

@end
