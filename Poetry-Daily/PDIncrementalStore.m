//
//  PDIncrementalStore.m
//  Poetry-Daily
//
//  Created by David Sklenar on 1/17/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDIncrementalStore.h"
#import "PDAPIClient.h"

@implementation PDIncrementalStore

+ (void)initialize;
{
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type;
{
    return NSStringFromClass(self);
}

+ (NSManagedObjectModel *)model;
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"PDModel" withExtension:@"xcdatamodeld"]];
}

- (id<AFIncrementalStoreHTTPClient>)HTTPClient;
{
    return [PDAPIClient sharedClient];
}

@end
