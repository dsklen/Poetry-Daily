//
//  PDAPIClient.h
//  Poetry-Daily
//
//  Created by David Sklenar on 1/17/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "AFRESTClient.h"
#import "AFIncrementalStore.h"

@interface PDAPIClient :AFRESTClient <AFIncrementalStoreHTTPClient>

+ (PDAPIClient *)sharedClient;

@end
