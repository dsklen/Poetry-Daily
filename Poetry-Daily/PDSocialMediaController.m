//
//  PDSocialMediaController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/5/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDSocialMediaController.h"
#import "PDConstants.h"
#import "PDTweet.h"

@implementation PDSocialMediaController

#pragma mark Properties

@synthesize operationQueue = _operationQueue;

#pragma mark API

+ (id)sharedSocialMediaController;
{
    static dispatch_once_t onceToken;
    static id sharedSocialMediaController = nil;
    
    dispatch_once( &onceToken, ^{
        sharedSocialMediaController = [[[self class] alloc] init];
    });
    
    return sharedSocialMediaController;
}

- (void)fetchTwitterItemsWithCompletionBlock:(PDFetchSocialMediaBlock)block;
{
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *urlString = @"https://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=Poetry_Daily&count=60";
        NSURL *URL = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSHTTPURLResponse *response;
        NSError *connectionError, *parsingError;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        NSDictionary *JSON = nil;
        
        if ( data ) 
        {
            JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
            
            for ( NSDictionary *dict in JSON )
            {
                PDTweet *tweet = [[PDTweet alloc] initWithJSON:dict];
                [array addObject:tweet];
            }                
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            if ( connectionError ) 
                block( nil, connectionError );
            else if ( parsingError )
                block( nil, parsingError );
            else 
                block(array, nil);
        });
    }];
    
    [self.operationQueue addOperation:fetch];
}

#pragma mark NSObject

- (id)init;
{
    if ( self = [super init] )
    {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

@end
