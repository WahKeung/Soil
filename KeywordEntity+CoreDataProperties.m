//
//  KeywordEntity+CoreDataProperties.m
//  Soil
//
//  Created by Mike on 21/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//
//

#import "KeywordEntity+CoreDataProperties.h"

@implementation KeywordEntity (CoreDataProperties)

+ (NSFetchRequest<KeywordEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"KeywordEntity"];
}

@dynamic value;

@end
