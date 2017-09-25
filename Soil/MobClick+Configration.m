//
//  MobClick+Configration.m
//  Soil
//
//  Created by Mike on 25/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MobClick+Configration.h"

@implementation MobClick (Configration)

+ (void)startServiceWithAppKey:(NSString *)appKey {
    UMConfigInstance.appKey = appKey;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
}

@end
