//
//  MYPhotoBrowser.m
//  Soil
//
//  Created by Mike on 28/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MYPhotoBrowser.h"

@interface MYPhotoBrowser ()<UIPageViewControllerDelegate>

@end

@implementation MYPhotoBrowser

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:^(void){
        if (completion) {
            completion();
        }
        if (self.dismissHandler) {
            self.dismissHandler();
        }
    }];
}

@end
