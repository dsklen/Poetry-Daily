//
//  PDCachedDataController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 5/31/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^PDCompletionBlock)(BOOL success, NSError *error);
typedef void (^PDCacheUpdateBlock)(NSArray *newResults);
typedef void (^PDCachedNewsUpdateBlock)(NSString *HTML, NSError *error);

/*
 * Handles cached media data through a Core Data store. All UI controllers 
 * should pull data from the shared instance of this class (the exception are
 * TV commands such as play, pause, etc which are sent directly to TVDevice).
 *
 * The fetch objects method immediately returns cached data from the data 
 * store, and also makes an API update call based on the current fetch request. 
 * The cache update block may be called twice; once when the media objects are
 * updated, and once when their thumbnails have been loaded. Errors are sent as 
 * an NSNotification object.
 */

@interface PDCachedDataController : NSObject

@property(strong) NSManagedObjectContext *context;
@property(strong) NSTimer *autosaveTimer;
@property(strong) NSTimer *purgeTimer;

+ (id)sharedDataController;

- (void)load:(PDCompletionBlock)block;
- (void)save:(PDCompletionBlock)block;

/*
 * Fetch objects from the cache. If the optional serverInfo dictionary and 
 * cacheUpdateBlock are provided, this method will also update the cache values
 * from the server and call the update block when finished.
 */

- (NSArray *)fetchObjects:(NSFetchRequest *)fetch serverInfo:(NSDictionary *)info cacheUpdateBlock:(PDCacheUpdateBlock)block;

@end
