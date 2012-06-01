//
//  PDCachedDataController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 5/31/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDCachedDataController.h"
#import "PDMediaServer.h"
#import "PDConstants.h"
#import "PDPoem.h"
#import "SVProgressHUD.h"

#define AUTOSAVE_BATCHING_INTERVAL 5.0
#define PURGE_OLD_DATA_INTERVAL 900.0


@interface PDCachedDataController()

- (NSString *)storePath;
- (NSDictionary *)localizationDictionary;

- (void)managedObjectsDidChange:(NSNotification *)aNotification;
- (void)autosave:(NSTimer *)aTimer;
- (void)purge:(NSTimer *)aTimer;

- (void)updateDisplayItems:(NSString *)serverKey existingObjects:(NSArray *)objects genre:(NSString *)genre type:(NSString *)type size:(NSInteger)size completionBlock:(TVCacheUpdateBlock)block;

@end


@implementation PDCachedDataController


#pragma mark Properties

@synthesize context = _context;
@synthesize autosaveTimer = _autosaveTimer;
@synthesize purgeTimer = _purgeTimer;


#pragma mark API

+ (id)sharedDataController;
{
    static dispatch_once_t onceToken;
    static id sharedDataController = nil;
    
    dispatch_once( &onceToken, ^{
        sharedDataController = [[[self class] alloc] init];
    });
    
    return sharedDataController;
}

- (void)load:(TVCompletionBlock)block;
{
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSURL *storeURL = [[NSURL alloc] initFileURLWithPath:[self storePath]];
    NSError *error = nil;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    [model setLocalizationDictionary:[self localizationDictionary]];
    
    if ( ![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error] )
    {
        block( NO, error );
    }
    else
    {
        self.context = [[NSManagedObjectContext alloc] init];
        [self.context setPersistentStoreCoordinator:coordinator];
        
        block( YES, nil );
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.context];
}

- (void)save:(TVCompletionBlock)block;
{
    NSAssert( self.context != nil, @"self.context must not be nil" );
    
    NSError *error = nil;
    
    if ( ![self.context save:&error] )
        block( NO, error );
    else
        block( YES, nil );
}

- (NSArray *)fetchObjects:(NSFetchRequest *)fetch serverInfo:(NSDictionary *)info cacheUpdateBlock:(TVCacheUpdateBlock)block;
{
    NSParameterAssert( fetch != nil );
    NSAssert( self.context != nil, @"self.context must not be nil" );
    
    PDMediaServer *server = [[PDMediaServer alloc] init];
    
    // A Dictionary is passed in with server command --> specifies which type of object
    // to update.
    
    NSInteger serverCommand = [[info objectForKey:@"CommandGoesHere"] integerValue];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:fetch error:&error];
    
    //    if ( server == nil || serverCommand == TVServerCommandNone )
    //        return results;
    //    
    //    switch ( serverCommand ) 
    //    {
    //        case TVServerCommandHomeRow:
    //            [self updateDisplayItems:[info objectForKey:TVHomeRowCategoryKey] existingObjects:results genre:@"" type:@"" size:[fetch fetchLimit] completionBlock:block];
    //            break;
    //        case TVServerCommandSearch:
    //            [self updateSearchResults:[info objectForKey:TVSearchStringKey] existingObjects:results completionBlock:block];
    //            break;
    //        case TVServerCommandGuide:
    //            [self updateGuideItemsForStartDate:[info objectForKey:TVGuideStartDateKey] endDate:[info objectForKey:TVGuideEndDateKey] completionBlock:block];
    //            break;
    //        case TVServerCommandDevices:
    //            [self updateConnectedDevices:results completionBlock:block];
    //            break;
    //        case TVServerCommandSeriesInfo:
    //            [self updateAvailableSeasonsAndEpisodesForAiringID:[info objectForKey:TVAiringIDKey] completionBlock:block];
    //            break;
    //        case TVServerCommandMediaItem:
    //            [self updateMediaItemForAiringID:[info objectForKey:TVAiringIDKey] cachedMediaItem:[[results lastObject] item] completionBlock:block];
    //            break;
    //        case TVServerCommandSeeAll:
    //            [self updateDisplayItems:[info objectForKey:TVHomeRowCategoryKey] existingObjects:results genre:[info objectForKey:TVDisplayObjectGenreKey] type:[info objectForKey:TVDisplayObjectTypeKey] size:-1 completionBlock:block];
    //            break;
    //    }
    
    return results;
}

#pragma mark Private API

- (NSString *)storePath;
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *URL = [manager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSString *appFolder = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *path = [[URL path] stringByAppendingPathComponent:appFolder];
    
    if ( ![manager fileExistsAtPath:path] )
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    path = [path stringByAppendingPathComponent:@"MediaData.poetrydaily"];
    
    return path;
}

- (NSDictionary *)localizationDictionary;
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            NSLocalizedString( @"Title", @"" ), @"Property/title/Entity/Poem", nil];
}

- (void)managedObjectsDidChange:(NSNotification *)aNotification;
{
    [self.autosaveTimer invalidate];
    self.autosaveTimer = [NSTimer scheduledTimerWithTimeInterval:AUTOSAVE_BATCHING_INTERVAL target:self selector:@selector(autosave:) userInfo:nil repeats:NO];
}

- (void)autosave:(NSTimer *)aTimer;
{
    NSError *error = nil;
    NSLog( @"Beginning autosave operation..." );
    
    [SVProgressHUD showWithStatus:NSLocalizedString( @"Saving Cache…", @"" ) maskType:SVProgressHUDMaskTypeBlack networkIndicator:YES];
    
    
    if ( ![self.context save:&error] && error != nil ) 
        NSLog( @"Warning: cache save failed (%@)", error );
    else 
        NSLog( @"Cache autosave finished." );
    
    
    [SVProgressHUD dismissWithSuccess:NSLocalizedString( @"Cache saved", @"" )];
    
    self.autosaveTimer = nil;
}

- (void)purge:(NSTimer *)aTimer;
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CacheObject"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.updatedOn < %@", [NSDate dateWithTimeIntervalSinceNow:-1209600]];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *items = [self.context executeFetchRequest:request error:&error];
    
    for ( NSManagedObject *object in items )
        [self.context deleteObject:object];
    
    NSLog( @"Purged %ld stale objects from cache.", (long)[items count] );
}


#pragma mark NSObject

- (id)init;
{
    if ( self = [super init] )
    {
        _purgeTimer = [NSTimer scheduledTimerWithTimeInterval:PURGE_OLD_DATA_INTERVAL target:self selector:@selector(purge:) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)dealloc;
{
    [_autosaveTimer invalidate];
    [_purgeTimer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:self.context];
}

@end
