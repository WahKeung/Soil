//
//  MYPhotoBrowser.h
//  Soil
//
//  Created by Mike on 28/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <SYPhotoBrowser/SYPhotoBrowser.h>

@interface MYPhotoBrowser : SYPhotoBrowser

@property (nonatomic, copy) void (^dismissHandler)(void);

@end
