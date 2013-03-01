//
//  PDMediaServer.h
//  Poetry-Daily
//
//  Created by David Sklenar on 5/31/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PDFetchBlock)(NSArray *items, NSError *error);

/*
 * Represents a networked media server. Calls to get JSON objects directly from
 * the server should go through this class. 
 */


@interface PDMediaServer : NSObject <NSURLConnectionDelegate>

@property(strong) NSOperationQueue *operationQueue;
@property(strong) NSOperationQueue *poemOperationQueue;
@property(strong) NSString *username;
@property(strong) NSString *password;

/*
 * TO DO: Add methods to hit PD API endpoints.
 */

- (void)fetchPoemWithID:(NSString *)poemID block:(PDFetchBlock)block;
- (void)fetchPoemArchiveWithBlock:(PDFetchBlock)block;
- (void)fetchPoetImagesWithStrings:(NSArray *)strings block:(PDFetchBlock)block;
- (void)fetchArbitraryImagesWithURLs:(NSArray *)URLs block:(PDFetchBlock)block;

- (NSString *)poemIDFromDate:(NSDate *)date;
- (NSDate *)dateFromPoemID:(NSString *)poemID;

- (NSDictionary *)JSONForCommand:(NSString *)command parameters:(NSDictionary *)parameters timeout:(NSTimeInterval)timeout error:(NSError *__autoreleasing *)error;
- (NSDictionary *)JSONForCommand:(NSString *)command parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error;

@end
