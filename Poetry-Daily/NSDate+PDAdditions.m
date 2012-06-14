//
//  NSDate+PDAdditions.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/14/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "NSDate+PDAdditions.h"

@implementation NSDate (PDAdditions)

+ (NSDate *)charlottesvilleDate;
{
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    
    return [NSDate date];
}

@end
