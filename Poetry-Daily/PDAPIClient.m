//
//  PDAPIClient.m
//  Poetry-Daily
//
//  Created by David Sklenar on 1/17/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDAPIClient.h"

static NSString * const kPoetryDailyAPIBaseURLString = @"http://poems.com/";

@implementation PDAPIClient

+ (PDAPIClient *)sharedClient;
{
    static PDAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
   
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kPoetryDailyAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url;
{
    self = [super initWithBaseURL:url];

    if ( !self )
        return nil;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}


#pragma mark - AFIncrementalStore

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *mutableURLRequest = nil;
    
    if ([fetchRequest.entityName isEqualToString:@"Poem"])
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"iphone.php" parameters:nil];
    
    return mutableURLRequest;
}

- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject;
{
    return [responseObject valueForKey:@"data"];
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
    
    if ( [entity.name isEqualToString:@"Poem"] )
    {
        [mutablePropertyValues setValue:[NSNumber numberWithInteger:[[representation valueForKey:@"id"] integerValue]] forKey:@"postID"];
        [mutablePropertyValues setValue:AFDateFromISO8601String([representation valueForKey:@"created_at"]) forKey:@"createdAt"];
    }
    else if ( [entity.name isEqualToString:@"User"] )
    {
        [mutablePropertyValues setValue:[NSNumber numberWithInteger:[[representation valueForKey:@"id"] integerValue]] forKey:@"userID"];
        [mutablePropertyValues setValue:[representation valueForKey:@"username"] forKey:@"username"];
        [mutablePropertyValues setValue:[representation valueForKeyPath:@"avatar_image.url"] forKey:@"avatarImageURLString"];
    }
    
    return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

@end