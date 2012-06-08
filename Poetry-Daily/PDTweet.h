//
//  PDTweet.h
//  Poetry-Daily
//
//  Created by David Sklenar on 6/5/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDTweet : NSObject

@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) NSString *screenNameString;
@property (nonatomic, strong) NSString *profileImageURL;

@property (nonatomic, strong) NSDate *createdAtDate;
@property (nonatomic, strong) NSString *tweetIDString;
@property (nonatomic, strong) NSString *tweetTextString;
@property (nonatomic) NSInteger retweetCount;
@property (nonatomic, strong) NSString *urlEntityString;

- (id)initWithJSON:(NSDictionary *)JSONObject;

@end
