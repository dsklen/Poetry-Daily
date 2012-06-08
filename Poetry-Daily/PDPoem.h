//
//  PDPoem.h
//  Poetry-Daily
//
//  Created by David Sklenar on 5/31/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PDPoem : NSManagedObject

@property (strong, nonatomic) NSString *author;
@property (assign, nonatomic) BOOL isFavorite;
@property (strong, nonatomic) NSString *journalTitle;
@property (strong, nonatomic) NSString *poemBody;
@property (strong, nonatomic) NSString *poemID;
@property (strong, nonatomic) NSDate *publishedDate;
@property (strong, nonatomic) NSString *title;

+ (PDPoem *)fetchOrCreatePoemWithID:(NSString *)poemID;
+ (PDPoem *)fetchOrCreatePoemWithID:(NSString *)poemID context:(NSManagedObjectContext *)context;
+ (id)fetchOrCreateObject:(NSString *)entityName withValue:(NSString *)value key:(NSString *)key context:(NSManagedObjectContext *)context;

@end
