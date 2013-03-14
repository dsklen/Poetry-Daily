//
//  PDSponsor.h
//  Poetry-Daily
//
//  Created by David Sklenar on 3/8/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreData/CoreData.h>

@interface PDSponsor : NSManagedObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *siteURL;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) UIImage *image;

+ (PDSponsor *)fetchOrCreateSponsorWithName:(NSString *)name;
+ (PDSponsor *)fetchOrCreateSponsorWithName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (id)fetchOrCreateObject:(NSString *)entityName withValue:(NSString *)value key:(NSString *)key context:(NSManagedObjectContext *)context;

@end
