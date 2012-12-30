//
//  PDTweet.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/5/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDTweet.h"

@implementation PDTweet

@synthesize nameString;
@synthesize screenNameString;
@synthesize profileImageURL;
@synthesize createdAtDate;
@synthesize tweetIDString;
@synthesize tweetTextString;
@synthesize retweetCount;
@synthesize urlEntityString;

- (id)initWithJSON:(NSDictionary *)JSONObject;
{
 	if (self = [super init]) {
        
        self.nameString = [[JSONObject objectForKey:@"user"] objectForKey:@"name"];
        self.screenNameString = [[JSONObject objectForKey:@"user"] objectForKey:@"screen_name"];
        self.profileImageURL = [[JSONObject objectForKey:@"user"] objectForKey:@"profile_image_url"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
        self.createdAtDate = [dateFormatter dateFromString:[JSONObject objectForKey:@"created_at"]];
        
        self.tweetIDString = [JSONObject objectForKey:@"id_str"];
        self.tweetTextString = [JSONObject objectForKey:@"text"];
        self.retweetCount = [[JSONObject objectForKey:@"retweet_count"] integerValue];
        
        if ( [[JSONObject objectForKey:@"entities"] objectForKey:@"urls"] )
          if ( [[[JSONObject objectForKey:@"entities"] objectForKey:@"urls"] lastObject] )
              self.urlEntityString = [[[[JSONObject objectForKey:@"entities"] objectForKey:@"urls"] lastObject] objectForKey:@"url"];
    }

    return self;
}

@end
