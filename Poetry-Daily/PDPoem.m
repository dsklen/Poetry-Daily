//
//  PDPoem.m
//  Poetry-Daily
//
//  Created by David Sklenar on 5/31/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDPoem.h"
#import "PDCachedDataController.h"

@implementation PDPoem

#pragma mark Properties

@dynamic author;
@dynamic isFavorite;
@dynamic journalTitle;
@dynamic poemBody;
@dynamic poemID;
@dynamic publishedDate;
@dynamic title;

#pragma mark API

+ (PDPoem *)fetchOrCreatePoemWithID:(NSString *)poemID;
{
    // By default, use the cache controller's managed object context. A seperate
    // context must be specified if this method is to be called on a background 
    // thread.
    
    return [self fetchOrCreatePoemWithID:poemID context:[[PDCachedDataController sharedDataController] context]];
}

+ (PDPoem *)fetchOrCreatePoemWithID:(NSString *)poemID context:(NSManagedObjectContext *)context;
{
    NSParameterAssert( [poemID length] > 0 );
    NSParameterAssert( context != nil );
    
    return [self fetchOrCreateObject:@"Poem" withValue:poemID key:@"poemID" context:context];
}

+ (id)fetchOrCreateObject:(NSString *)entityName withValue:(NSString *)value key:(NSString *)key context:(NSManagedObjectContext *)context;
{
    NSParameterAssert( [entityName length] > 0 );
    NSParameterAssert( [value length] > 0 );
    NSParameterAssert( [key length] > 0 );
    NSParameterAssert( context != nil );
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.%@ == %@", key, value];
    
    request.fetchLimit = 1;
    request.predicate = predicate;
    
    NSArray *results = [context executeFetchRequest:request error:NULL];
    NSManagedObject *object = [results lastObject];
    
    if ( object == nil )
    {
        object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        [object setValue:value forKey:key];
    }
    
    NSAssert( object != nil, @"failed to create managed object" );
    
    return object;
}

@end
