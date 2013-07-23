//
//  PDMediaServer.m
//  Poetry-Daily
//
//  Created by David Sklenar on 5/31/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDMediaServer.h"
#import "NSDate+PDAdditions.h"
#define DEFAULT_TIMEOUT 60.0


@interface PDMediaServer ()

- (NSString *)poemIDFromDate:(NSDate *)date;
- (NSString *)poemIDForToday;
@end


@implementation PDMediaServer


#pragma mark Properties

@synthesize operationQueue = _operationQueue;
@synthesize poemOperationQueue = _poemOperationQueue;
@synthesize featureOperationQueue = _featureOperationQueue;
@synthesize username = _username;
@synthesize password = _password;


#pragma mark - Public API


- (void)fetchNewsHTML:(PDNewsFetchBlock)block;
{
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
        
        NSError *error = nil;
        
        NSMutableString *URLString = [NSMutableString stringWithString:@"http://poems.com/news.php"];
                
        NSURL *URL = [NSURL URLWithString:URLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
        NSHTTPURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if ( [data length] == 0 && error != NULL && error == nil )
            error = [[NSError alloc] initWithDomain:@"Connect Error" code:1000 userInfo:nil];
        
        NSString *HTML = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        NSString *HTML = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];

        if ( [HTML length] == 0 && error != NULL && error == nil )
            error = [[NSError alloc] initWithDomain:@"Connect Error" code:1000 userInfo:nil];
        
        NSRange r_s = [HTML rangeOfString:@"<a name=\"breaking\" id=\"breaking\"></a><span class=\"page_subtitle\">In the News</span>:</p>"];                           // find where poem starts
        NSUInteger f = r_s.location+r_s.length;                                             // 'from' index
        
        NSRange r_e = [[HTML substringFromIndex:f] rangeOfString:@"<p><strong><a name=\"recent\" id=\"recent\">"];               // find where poem ends
        NSUInteger t = r_e.location;                                                        // 'to' index
        
        NSString *b = [[NSString alloc] initWithString:[HTML substringFromIndex:f]];
        NSString *p_b = [[NSString alloc] initWithString:[b substringToIndex:t]];
        
        
        NSString *style = @"<html><head><style type=\"text/css\"> body {font-family:helvetica,sans-serif; font-size: 50px;  white-space:normal; padding:20px; margin:0px;}</style><script></script></head><body><div>";
        
        NSString *p_b_style = [style stringByAppendingString:p_b];
        NSString *final = [p_b_style stringByAppendingString:@"</div></body></html>"];

        dispatch_async( dispatch_get_main_queue(), ^{
            
            if ( HTML == nil && error != nil )
                block( nil, error );
            else
                block( final, nil );
        });
    }];
    
    [self.operationQueue addOperation:fetch];
}

- (void)fetchFeatureWithID:(NSString *)poemID block:(PDFetchBlock)block;
{
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
        
        NSError *error = nil;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        [params setObject:poemID forKey:@"date"];
        
        NSDictionary *JSON = [self JSONForCommand:@"feature_mobile" parameters:params error:&error];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            if ( JSON == nil && error != nil )
                block( nil, error );
            else
                block( [NSArray arrayWithObject:JSON], nil );
        });
    }];
    
    [self.poemOperationQueue cancelAllOperations];
    [self.poemOperationQueue addOperation:fetch];
}

- (void)fetchPoemWithID:(NSString *)poemID block:(PDFetchBlock)block;
{
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
     
     NSError *error = nil;
     NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
         
    [params setObject:poemID forKey:@"date"];
          
     NSDictionary *JSON = [self JSONForCommand:@"poem_mobile" parameters:params error:&error];
     
     dispatch_async( dispatch_get_main_queue(), ^{
     
     if ( JSON == nil && error != nil )
        block( nil, error );
     else
        block( [NSArray arrayWithObject:JSON], nil );
        });
     }];
    
    [self.poemOperationQueue cancelAllOperations];
    [self.poemOperationQueue addOperation:fetch];
}

- (void)fetchPoemArchiveWithBlock:(PDFetchBlock)block;
{
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
        
        NSError *error = nil;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                
        NSDictionary *JSON = [self JSONForCommand:@"iphoneArchive" parameters:params error:&error];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            if ( JSON == nil && error != nil )
                block( nil, error );
            else
                block( [NSArray arrayWithObject:JSON], nil );
        });
    }];
    
    [self.operationQueue addOperation:fetch];
}

- (void)fetchSponsorsWithBlock:(PDFetchBlock)block;
{
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
        
        NSError *error = nil;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        NSDictionary *JSON = [self JSONForCommand:@"sponsors_mobile" parameters:params error:&error];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            if ( JSON == nil && error != nil )
                block( nil, error );
            else
                block( @[JSON], nil );
        });
    }];
    
    [self.operationQueue addOperation:fetch];
}

- (void)fetchPoetImagesWithStrings:(NSArray *)strings isJournalImage:(BOOL)isJournal block:(PDFetchBlock)block;
{
    NSParameterAssert( strings != nil );
    NSParameterAssert( block != nil );
    
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[strings count]];
        NSError *error = nil;
        
        for ( NSString *address in strings )
        {
            NSURL *URL = nil;
            
            if ( isJournal )
            {                
                URL =[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://poems.com/images/_books-journals/%@", address]];
            }
            else
                URL =[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://poems.com/images/_poets/%@", address]];
            
            NSLog(@"Fetching Image at URL: %@", [URL absoluteString] );
            NSError *error = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            NSHTTPURLResponse *response = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if ( data == nil )
                data = (id)[NSNull null];            
            
            [results addObject:data];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            block( results, error );
        });
    }];
    
//    [fetch setQueuePriority:NSOperationQueuePriorityLow];
    
    [self.operationQueue addOperation:fetch];
}

- (void)fetchSponsorImagesWithStrings:(NSArray *)strings block:(PDFetchBlock)block;
{
    NSParameterAssert( strings != nil );
    NSParameterAssert( block != nil );
    
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[strings count]];
        NSError *error = nil;
        
        for ( NSString *address in strings )
        {
            NSURL *URL = nil;
            

            URL =[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://poems.com/images/_features-sponsors/%@", address]];
            
            NSLog(@"Fetching Image at URL: %@", [URL absoluteString] );
            NSError *error = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            NSHTTPURLResponse *response = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if ( data == nil )
                data = (id)[NSNull null];
            
            [results addObject:data];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            block( results, error );
        });
    }];
    
    //    [fetch setQueuePriority:NSOperationQueuePriorityLow];
    
    [self.operationQueue addOperation:fetch];
}

- (void)fetchArbitraryImagesWithURLs:(NSArray *)URLs block:(PDFetchBlock)block;
{
    NSParameterAssert( URLs != nil );
    NSParameterAssert( block != nil );
    
    NSBlockOperation *fetch = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[URLs count]];
        NSError *error = nil;
        for ( NSURL *URL in URLs )
        {
            
            NSLog(@"Fetching Image at URL: %@", [URL absoluteString] );
            NSError *error = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            NSHTTPURLResponse *response = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            if ( image == nil )
                image = (id)[NSNull null];
            
            [results addObject:image];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            block( results, error );
        });
    }];
    
    [fetch setQueuePriority:NSOperationQueuePriorityLow];
    
    [self.operationQueue addOperation:fetch];
}

- (NSDictionary *)JSONForCommand:(NSString *)command parameters:(NSDictionary *)parameters timeout:(NSTimeInterval)timeout error:(NSError *__autoreleasing *)error;
{
    NSParameterAssert( timeout > 0 );
    NSParameterAssert( [command length] > 0 );
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
//    [mutableParams setObject:@"json" forKey:@"encoder"];
    
    NSMutableString *URLString = [NSMutableString stringWithString:@"http://poems.com"];
    
    [URLString appendFormat:@"/%@.php?", command];
    [mutableParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { [URLString appendFormat:@"&%@=%@", key, obj]; }];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSLog(@"%@", URLString);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    if ( [data length] == 0 && error != NULL && *error == nil )
        *error = [[NSError alloc] initWithDomain:@"Connect Error" code:1000 userInfo:nil];
    
    if ( [data length] == 0 )
        return nil;
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    
    if ( [JSON count] == 0 && error != NULL && *error == nil )
        *error = [[NSError alloc] initWithDomain:@"Connect Error" code:1000 userInfo:nil];
    
    return JSON;
}

- (NSDictionary *)JSONForCommand:(NSString *)command parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error;
{
    return [self JSONForCommand:command parameters:parameters timeout:DEFAULT_TIMEOUT error:error];
}

- (NSString *)poemIDFromDate:(NSDate *)date;
{
    NSDate *referenceDate = [NSDate dateWithTimeIntervalSince1970:1269881100.0f];
    
    int difference = (int)[date timeIntervalSinceDate:referenceDate];
    int poemIDInt = difference / 60 / 60 / 24 + 14698;
        
    return [NSString stringWithFormat:@"%i", poemIDInt];
}

- (NSDate *)dateFromPoemID:(NSString *)poemID;
{
    int intPoemID = [poemID intValue];
    int difference = (intPoemID - 14698 ) * 60 * 60 * 24 ;
    NSDate *referenceDate = [NSDate dateWithTimeIntervalSince1970:1269881100.0f];

    return [referenceDate dateByAddingTimeInterval:difference];
}

- (NSString *)poemIDForToday;
{
    return [self poemIDFromDate:[NSDate charlottesvilleDate]];
}

#pragma mark NSObject

- (id)init;
{
    if ( ( self = [super init] ) )
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 4;
        
        _poemOperationQueue = [[NSOperationQueue alloc] init];
        _poemOperationQueue.maxConcurrentOperationCount = 1;

        _featureOperationQueue = [[NSOperationQueue alloc] init];
        _featureOperationQueue.maxConcurrentOperationCount = 1;

        _username = [NSString stringWithFormat:@"poems"];
        _password = [NSString stringWithFormat:@"all_day"];
        
        if ([_username length] == 0 || [_password length] == 0) {
            NSError *error = [NSError errorWithDomain:@"No server login credentials" code:401 userInfo:nil];
            NSLog(@"%@", error);
        }
    }
    
    return self;
}


@end
