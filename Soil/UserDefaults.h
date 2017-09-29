//
//  UserDefaults.h
//  Soil
//
//  Created by Mike on 29/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaults : NSObject

+ (instancetype)userDefault;

@property (nonatomic, assign) BOOL showRate;
@property (nonatomic, assign) BOOL showBody;

@end
