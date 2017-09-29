//
//  UserDefaults.m
//  Soil
//
//  Created by Mike on 29/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

+ (instancetype)userDefault {
    static dispatch_once_t onceToken;
    static UserDefaults *userDefault = nil;
    
    dispatch_once(&onceToken, ^{
        userDefault = [[UserDefaults alloc] init];
    });
    return userDefault;
}

- (BOOL)showBody {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"showBody"];
}

- (void)setShowBody:(BOOL)showBody {
    [[NSUserDefaults standardUserDefaults] setBool:showBody forKey:@"showBody"];
}

- (BOOL)showRate {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"showRate"];
}

- (void)setShowRate:(BOOL)showRate {
    [[NSUserDefaults standardUserDefaults] setBool:showRate forKey:@"showRate"];
}

@end
