//
//  PDSponsor.m
//  Poetry-Daily
//
//  Created by David Sklenar on 3/8/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDSponsor.h"
#import "PDCachedDataController.h"

@implementation PDSponsor



#pragma mark - Properties

@dynamic name;
@dynamic text;
@dynamic siteURL;
@dynamic imageURL;
@dynamic imageData;
@dynamic image;

- (UIImage *)image;
{
    UIImage *image = [UIImage imageWithData:self.imageData];
    
    // Return a placeholder image if the real avatar hasn't been set or
    // isn't available.
    
    // TODO: specify user avatar default.
    
    //    if ( image == nil )
    //    {
    //        image = [UIImage imageNamed:@""];
    //    }

    return image;
}

- (void)setImage:(UIImage *)image;
{
    // If you're using this method, keep in mind you will probably get better
    // performance if you use setAvatarData: directly (assuming you're not
    // dealing with an existing UIImage).
    
    [self setImageData:UIImagePNGRepresentation( image )];
}

#pragma mark - API

+ (PDSponsor *)fetchOrCreateSponsorWithName:(NSString *)name;
{
    // By default, use the cache controller's managed object context. A seperate
    // context must be specified if this method is to be called on a background
    // thread.
    
    return [self fetchOrCreateSponsorWithName:name context:[[PDCachedDataController sharedDataController] context]];
}

+ (PDSponsor *)fetchOrCreateSponsorWithName:(NSString *)name context:(NSManagedObjectContext *)context;
{
    NSParameterAssert( [name length] > 0 );
    NSParameterAssert( context != nil );
    
    return [self fetchOrCreateObject:@"Sponsor" withValue:name key:@"name" context:context];
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
