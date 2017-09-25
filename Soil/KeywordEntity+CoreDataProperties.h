//
//  KeywordEntity+CoreDataProperties.h
//  Soil
//
//  Created by Mike on 21/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//
//

#import "KeywordEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface KeywordEntity (CoreDataProperties)

+ (NSFetchRequest<KeywordEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *value;

@end

NS_ASSUME_NONNULL_END
