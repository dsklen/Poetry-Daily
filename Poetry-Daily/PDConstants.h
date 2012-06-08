//
//  PDConstants.h
//  Poetry-Daily
//
//  Created by David Sklenar on 5/31/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *PDServerCommandKey;
extern NSString *PDPoemKey;
extern NSString *PDAllPoemsKey;

typedef enum 
{
    PDServerCommandNone = 0,
    PDServerCommandPoem,
    PDServerCommandAllPoems
} PDCacheServerCommand;
