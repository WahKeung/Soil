//
//  ResultModel.h
//  Soil
//
//  Created by Mike on 19/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) BOOL isAD;
@property (nonatomic, assign) BOOL showInterstitial;

@end
