//
//  HistoryCollectionViewCell.m
//  Soil
//
//  Created by Mike on 20/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "HistoryCollectionViewCell.h"

@implementation HistoryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 4;
    self.layer.backgroundColor = [UIColor colorWithRed:119/256.0 green:143/256.0 blue:168/256.0 alpha:1].CGColor;
}

@end
