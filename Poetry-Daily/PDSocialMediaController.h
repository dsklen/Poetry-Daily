//
//  PDSocialMediaController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 6/5/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^PDFetchSocialMediaBlock)(NSArray *items, NSError *error);

/*
 * Controller to handle social media services.
 */

@interface PDSocialMediaController : NSObject

@property(strong) NSOperationQueue *operationQueue;

+ (id)sharedSocialMediaController;

- (void)fetchTwitterItemsWithCompletionBlock:(PDFetchSocialMediaBlock)block;

@end