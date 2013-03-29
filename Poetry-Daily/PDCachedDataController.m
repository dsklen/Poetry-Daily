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
#import "PDSponsor.h"

#import "SVProgressHUD.h"

#define AUTOSAVE_BATCHING_INTERVAL 5.0
#define PURGE_OLD_DATA_INTERVAL 900.0


@interface PDCachedDataController()

- (NSString *)storePath;
- (NSDictionary *)localizationDictionary;

- (void)managedObjectsDidChange:(NSNotification *)aNotification;
- (void)autosave:(NSTimer *)aTimer;
- (void)purge:(NSTimer *)aTimer;

- (void)updatePoemWithID:(NSString *)poemID completionBlock:(PDCacheUpdateBlock)block;
- (void)updatePoemArchiveWithExistingObjects:(NSArray *)existingPoems completionBlock:(PDCacheUpdateBlock)block;

- (void)updateSponsorsWithExistingItems:(NSArray *)existingSponsors completionBlock:(PDCacheUpdateBlock)block;

- (void)returnNewsWithBlock:(PDCachedNewsUpdateBlock)block;

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

- (void)load:(PDCompletionBlock)block;
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

- (void)save:(PDCompletionBlock)block;
{
    NSAssert( self.context != nil, @"self.context must not be nil" );
    
    NSError *error = nil;
    
    if ( ![self.context save:&error] )
        block( NO, error );
    else
        block( YES, nil );
}

- (NSArray *)fetchObjects:(NSFetchRequest *)fetch serverInfo:(NSDictionary *)info cacheUpdateBlock:(PDCacheUpdateBlock)block;
{
    NSParameterAssert( fetch != nil );
    NSAssert( self.context != nil, @"self.context must not be nil" );
    
    PDMediaServer *server = [[PDMediaServer alloc] init];
    
    // A Dictionary is passed in with server command --> specifies which type of object
    // to update.
    NSInteger serverCommand = [[info objectForKey:PDServerCommandKey] integerValue];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:fetch error:&error];
    
     if ( server == nil || serverCommand == PDServerCommandNone )
         return results;
     
     switch ( serverCommand ) 
     {
         case PDServerCommandPoem:
             [self updatePoemWithID:[info objectForKey:PDPoemKey] completionBlock:block];
             break;
         case PDServerCommandAllPoems:
             [self updatePoemArchiveWithExistingObjects:results completionBlock:block];
             break;
         case PDServerCommandSponsors:
             [self updateSponsorsWithExistingItems:results completionBlock:block];
             break;
             
//         ....etc.
     }
    
    return results;
}

- (void)returnNewsWithBlock:(PDCachedNewsUpdateBlock)block;
{
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"News"];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.isCurrent == TRUE"];
    request.fetchLimit = 1;
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];

    NSString *HTML = [results lastObject];
    
    if ( results && error == nil )
        block( HTML, nil );
}

- (void)updatePoemWithID:(NSString *)poemID completionBlock:(PDCacheUpdateBlock)block;
{
    PDMediaServer *server = [[PDMediaServer alloc] init];
    
    [server fetchPoemWithID:poemID block:^(NSArray *items, NSError *error) {
        
        if ( error != nil && items == nil )
        {
            block( nil, error );
            return;
        }
    
        PDPoem *poem = [PDPoem fetchOrCreatePoemWithID:poemID];

        NSDictionary *poemAttributesDictionary = [items lastObject];

        poem.poemID = poemID;
        
        NSMutableString *titleWithAttributes = [[poemAttributesDictionary objectForKey:@"title"] mutableCopy];
        titleWithAttributes = [[titleWithAttributes stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"] mutableCopy];
        poem.title = titleWithAttributes;
        
        poem.poemBody = [poemAttributesDictionary objectForKey:@"text"];
        poem.author = [NSString stringWithFormat:@"%@ %@", [poemAttributesDictionary objectForKey:@"poetFN"], [poemAttributesDictionary objectForKey:@"poetLN"]];;
        poem.journalTitle = [poemAttributesDictionary objectForKey:@"jName"];
        
        poem.publishedDate = [server dateFromPoemID:poemID];
        
        poem.isProse = [[poemAttributesDictionary objectForKey:@"fixed"] boolValue];
        
        NSString *imageAddress = [poemAttributesDictionary objectForKey:@"pImage"];
        
        if ( [imageAddress length] == 0 )
        {
            imageAddress = [poemAttributesDictionary objectForKey:@"journalImage"];
            poem.isJournalImage = YES;
        }
        
        poem.authorImageURLString = imageAddress;
        
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            if ( poem == nil && error )
                block( nil, error );
            else
                block( [NSArray arrayWithObject:poem], nil );
        });

    }];
}


- (void)updatePoemArchiveWithExistingObjects:(NSArray *)existingPoems completionBlock:(PDCacheUpdateBlock)block;
{
    
   NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastArchiveUpdate"];
    
    
    NSLog(@"%f", [date timeIntervalSinceDate:[NSDate date]]);
    if ( date )
        if ( [date timeIntervalSinceDate:[NSDate date]] < -60 * 5)
            return;
    
    
    PDMediaServer *server = [[PDMediaServer alloc] init];
    
    [server fetchPoemArchiveWithBlock:^(NSArray *items, NSError *error) {
       
        if ( error != nil && items == nil )
        {
            block( nil, error );
            return;
        }      
        
        NSArray *allPoems = [items lastObject];
        NSMutableArray *updatedPoems = [[NSMutableArray alloc] init];
        NSMutableArray *imagesToFetch = [[NSMutableArray alloc] init];
        NSMutableDictionary *poemsToFetchImages = [[NSMutableDictionary alloc] init];

        if ( [allPoems count] > 0 )
        {
//            dispatch_async( dispatch_get_main_queue(), ^{
            
//                [SVProgressHUD showWithStatus:@"Archiving..."]; });
        }
        
        for ( NSDictionary *poemDescriptionDictionary in allPoems )
        {
            NSString *poemID = [[poemDescriptionDictionary allKeys] lastObject];
            NSDictionary *poemAttributesDictionary = [poemDescriptionDictionary objectForKey:poemID];
            
            PDPoem *poem = [PDPoem fetchOrCreatePoemWithID:poemID];
            
            poem.poemID = poemID;
            
            PDMediaServer *server = [[PDMediaServer alloc] init];
            
            poem.publishedDate = [server dateFromPoemID:poemID];
            
            NSMutableString *titleWithAttributes = [[poemAttributesDictionary objectForKey:@"title"] mutableCopy];
            titleWithAttributes = [[titleWithAttributes stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"] mutableCopy];            
            poem.title = titleWithAttributes;
            
            poem.author = [NSString stringWithFormat:@"%@ %@", [poemAttributesDictionary objectForKey:@"poetFN"], [poemAttributesDictionary objectForKey:@"poetLN"], nil];
            
            NSString *imageAddress = [poemAttributesDictionary objectForKey:@"pImage"];
            
            if ( [imageAddress length] == 0 )
            {
                imageAddress = [poemAttributesDictionary objectForKey:@"jImage"];
                poem.isJournalImage = YES;
            }
            
            poem.authorImageURLString = imageAddress;
            
            if ( poem.authorImageData == nil && [imageAddress length] > 0  )
            {
                [poemsToFetchImages setObject:poem forKey:imageAddress];
                [imagesToFetch addObject:imageAddress];
            }
            
            [updatedPoems addObject:poem];
        }
        

        
//        dispatch_async( dispatch_get_main_queue(), ^{ [SVProgressHUD dismiss]; });
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastArchiveUpdate"];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            if ( updatedPoems == nil && error )
                block( nil, error );
            else
                block( updatedPoems, nil );
        });

//        [server fetchPoetImagesWithStrings:imagesToFetch block:^(NSArray *items, NSError *error) {
//            
//            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                
////                if ( [obj ] == 0 )
////                    return;
//                
//                NSString *address = [imagesToFetch objectAtIndex:idx];
//                PDPoem *poem = (PDPoem *)[poemsToFetchImages objectForKey:address];
//                
//                if ( obj != [NSNull null] )
//                    poem.authorImageData = obj;
//                
////                NSError *error = nil;
////                if ( ![self.backgroundContext save:&error] )
////                    NSLog( @"Core Data save failed" );
//                
//            }];
//            
//            block( updatedPoems );
//        }];

    }];
}

- (void)updateSponsorsWithExistingItems:(NSArray *)existingSponsors completionBlock:(PDCacheUpdateBlock)block;
{
    PDMediaServer *server = [[PDMediaServer alloc] init];

    [server fetchSponsorsWithBlock:^(NSArray *items, NSError *error) {
    
        if ( error != nil && items == nil )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetUpErrorHandlingNotificationHere" object:error];
            block ( nil, error );

            return;
        }
        
        NSArray *allSponsors = [items lastObject];
        NSMutableArray *updatedSponsors = [[NSMutableArray alloc] init];
        
        for ( NSDictionary *sponsorDescriptionDictionary in allSponsors )
        {
            NSString *sponsorName = [sponsorDescriptionDictionary objectForKey:@"sponsorName"];
         
            PDSponsor *sponsor = [PDSponsor fetchOrCreateSponsorWithName:sponsorName];
            
            sponsor.name = sponsorName;
            sponsor.text = [sponsorDescriptionDictionary objectForKey:@"sponsorText"];
            sponsor.imageURL = [sponsorDescriptionDictionary objectForKey:@"sponsorImage"];
            sponsor.siteURL = [sponsorDescriptionDictionary objectForKey:@"sponsorUrl"];

            [updatedSponsors addObject:sponsor];
        }
        
        if ( updatedSponsors && !error )
            block( updatedSponsors, nil );
        else
            block ( nil, error );
        
        for ( PDSponsor *sponsor in updatedSponsors )
        {
            if ( sponsor.imageData == nil )
            {
                [server fetchSponsorImagesWithStrings:@[sponsor.imageURL] block:^(NSArray *items, NSError *error) {
                    
                    if ( items && !error )
                    {
                        NSData *newImageData = items[0];
                        sponsor.imageData = newImageData;
                    
                        block ( updatedSponsors, nil );
                    }
                    
                }];
            }
        }
    }];
    
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
    
//    [SVProgressHUD showWithStatus:NSLocalizedString( @"Saving Cache…", @"" ) maskType:SVProgressHUDMaskTypeBlack networkIndicator:YES];
    
    
    if ( ![self.context save:&error] && error != nil ) 
        NSLog( @"Warning: cache save failed (%@)", error );
    else 
        NSLog( @"Cache autosave finished." );
    
    
//    [SVProgressHUD dismissWithSuccess:NSLocalizedString( @"Cache saved", @"" )];
    
    self.autosaveTimer = nil;
}

- (void)purge:(NSTimer *)aTimer;
{
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CacheObject"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.updatedOn < %@", [NSDate dateWithTimeIntervalSinceNow:-1209600]];
//    
//    request.predicate = predicate;
//    
//    NSError *error = nil;
//    NSArray *items = [self.context executeFetchRequest:request error:&error];
//    
//    for ( NSManagedObject *object in items )
//        [self.context deleteObject:object];
//    
//    NSLog( @"Purged %ld stale objects from cache.", (long)[items count] );
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
