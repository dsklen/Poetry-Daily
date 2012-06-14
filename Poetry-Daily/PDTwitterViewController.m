//
//  PDTwitterViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/5/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDTwitterViewController.h"
#import "PDSocialMediaController.h"
#import "PDMediaServer.h"
#import "PDTweet.h"
#import "SVWebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "SVProgressHUD.h"

@interface PDTwitterViewController ()

- (IBAction)tweetTapped:(id)sender;

@end

@implementation PDTwitterViewController

@synthesize tweetsArray = _tweetsArray;
@synthesize tweetsTableView = _tweetsTableView;
@synthesize pdLogoImage = _pdLogoImage;

#pragma mark - API

- (IBAction)tweetTapped:(id)sender;
{ 
    UITableViewCell *detailCell = (UITableViewCell *)[[sender superview] superview];

    NSIndexPath *indexPath = [self.tweetsTableView indexPathForCell:detailCell];
    
    PDTweet *tweet = [self.tweetsArray objectAtIndex:indexPath.row];
    
    if ([TWTweetComposeViewController canSendTweet])
    {        
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"RT @Poetry_Daily %@", tweet.tweetTextString]];
        [self presentModalViewController:tweetSheet animated:YES];
    }
}

- (IBAction)tweetAtPD:(id)sender;
{
    if ([TWTweetComposeViewController canSendTweet])
    {        
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:@"@Poetry_Daily"];
        [self presentModalViewController:tweetSheet animated:YES];
    }
}

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"News", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"23-bird"];
        _tweetsArray = [NSArray array];
        _pdLogoImage = [[UIImage alloc] init];
        
        NSDictionary *titleTextAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont boldSystemFontOfSize:10.0f], UITextAttributeFont,
                                                       [UIColor darkGrayColor], UITextAttributeTextColor,
                                                       nil];
        
        NSDictionary *titleTextHighlightedAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont boldSystemFontOfSize:10.0f], UITextAttributeFont,
                                                                  [UIColor blackColor], UITextAttributeTextColor,
                                                                  nil];
        
        [self.tabBarItem setTitleTextAttributes:titleTextAttributesDictionary forState:UIControlStateNormal];
        [self.tabBarItem setTitleTextAttributes:titleTextHighlightedAttributesDictionary forState:UIControlStateSelected];


    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    self.tweetsTableView.alpha = 0.0f;
    
    [SVProgressHUD showWithStatus:@"Loading Tweets..."];
    
    PDMediaServer *server = [[PDMediaServer alloc] init];
    PDSocialMediaController *twitterController = [PDSocialMediaController sharedSocialMediaController];
    
    [twitterController fetchTwitterItemsWithCompletionBlock:^(NSArray *items, NSError *error) {
        
        if (error == nil && items) {
            self.tweetsArray = items;
            [self.tweetsTableView reloadData];
                  
            PDTweet *aTweet = (PDTweet *)[self.tweetsArray objectAtIndex:0]; 
            NSString *pdLogoURLString = (NSString *)[aTweet profileImageURL];
            NSURL *pdLogoURL = [NSURL URLWithString:pdLogoURLString];
              
            [server fetchArbitraryImagesWithURLs:[NSArray arrayWithObject:pdLogoURL] block:^(NSArray *items, NSError *error) {
              
                  if ( error == nil && items) {
                      self.pdLogoImage = [items lastObject];
                      [self.tweetsTableView reloadData];
                  }
              
            }];
            
            [UIView animateWithDuration:0.5f animations:^{
                self.tweetsTableView.alpha = 1.0f;
            }];
        }
        
        [SVProgressHUD dismiss];
    }];
    
    
    UIBarButtonItem *atPDBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(tweetAtPD:)];
    self.navigationItem.rightBarButtonItem = atPDBarButtonItem;
    atPDBarButtonItem.enabled = [TWTweetComposeViewController canSendTweet];
}

- (void)viewDidUnload
{
    [self setTweetsTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    PDTweet *tweet = [self.tweetsArray objectAtIndex:indexPath.row];
    NSString *string = tweet.tweetTextString;
    CGSize maximumLabelSize = CGSizeMake( 200.0f, 9999.0f );
    CGSize expectedLabelSize = [string sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
    
    return expectedLabelSize.height + 55.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    PDTweet *tweet = [self.tweetsArray objectAtIndex:indexPath.row];

    NSURL *URL = [NSURL URLWithString:tweet.urlEntityString];
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
    webViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:webViewController animated:YES];
}


#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.tweetsArray count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 50.0f, 50.0f)];
        thumbnailImageView.tag = 99;
        thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        thumbnailImageView.clipsToBounds = YES;
        thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
        thumbnailImageView.clipsToBounds = NO;
        thumbnailImageView.layer.cornerRadius = 3.0f;
        thumbnailImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        thumbnailImageView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
        thumbnailImageView.layer.shadowRadius = 2.0f;
        thumbnailImageView.layer.shadowOpacity = 0.5f;       
        thumbnailImageView.layer.shouldRasterize = YES;
        thumbnailImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [cell.contentView addSubview:thumbnailImageView];
        
        UILabel *tweeterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 5.0f, 200.0f, 20.0f)];
        tweeterNameLabel.tag = 100;
        tweeterNameLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        tweeterNameLabel.textAlignment = UITextAlignmentLeft;
        tweeterNameLabel.textColor = [UIColor blackColor];
        tweeterNameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:tweeterNameLabel];
        
        UILabel *tweeterScreennameLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0f, 5.0f, 85.0f, 20.0f)];
        tweeterScreennameLabel.tag = 101;
        tweeterScreennameLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        tweeterScreennameLabel.textAlignment = UITextAlignmentLeft;
        tweeterScreennameLabel.textColor = [UIColor grayColor];
        tweeterScreennameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:tweeterScreennameLabel];
        
        UILabel *publishedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(270.0f, 5.0f, 45.0f, 20.0f)];
        publishedDateLabel.tag = 102;
        publishedDateLabel.textAlignment = UITextAlignmentLeft;
        publishedDateLabel.font = [UIFont systemFontOfSize:12.0f];
        publishedDateLabel.textColor = [UIColor grayColor];
        publishedDateLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:publishedDateLabel];   
        
        UILabel *tweetTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 25.0f, 200.0f, 20.0f)];
        tweetTextLabel.tag = 103;
        tweetTextLabel.numberOfLines = 0;
        tweetTextLabel.font = [UIFont systemFontOfSize:12.0f];
        tweetTextLabel.textAlignment = UITextAlignmentLeft;
        tweetTextLabel.textColor = [UIColor darkGrayColor];
        tweetTextLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:tweetTextLabel];
        
        UILabel *retweetCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(132.0f, 30.0f, 200.0f, 20.0f)];
        retweetCountLabel.tag = 104;
        retweetCountLabel.textAlignment = UITextAlignmentLeft;
        retweetCountLabel.font = [UIFont systemFontOfSize:11.0f];
        retweetCountLabel.textColor = [UIColor grayColor];
        retweetCountLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:retweetCountLabel];
        
        
        if ( [TWTweetComposeViewController canSendTweet] ) 
        {
            UIButton *retweetButton = [UIButton buttonWithType:UIButtonTypeCustom];
            retweetButton.tag = 105;
            retweetButton.frame = CGRectMake(170.0f, 0.0f, 60.0f, 20.0f);
            retweetButton.alpha = 0.6f;
            [retweetButton setTitle:@"RT" forState:UIControlStateNormal];
            [retweetButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [retweetButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            retweetButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            
            [retweetButton addTarget:self action:@selector(tweetTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:retweetButton];
        }
        
        UIImageView *retweetIcon = [[UIImageView alloc] initWithFrame:CGRectMake(115.0f, 30.0f, 12.0f, 12.0f)];
        retweetIcon.image = [UIImage imageNamed:@"spechbubble_sq_line_black"];
        retweetIcon.alpha = 0.4;
        retweetIcon.tag = 106;
        retweetIcon.contentMode = UIViewContentModeScaleAspectFill;
        retweetIcon.clipsToBounds = YES;
        retweetIcon.backgroundColor = [UIColor clearColor];
        retweetIcon.layer.shouldRasterize = YES;
        retweetIcon.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [cell.contentView addSubview:retweetIcon];
        
        
        cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper"]];
        cell.accessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper"]];
    }
    
    PDTweet *tweet = [self.tweetsArray objectAtIndex:indexPath.row];
    
    UILabel *tweeterNameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    tweeterNameLabel.text = tweet.nameString;
    
    
    UILabel *tweeterScreenNameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    tweeterScreenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.nameString];
    
    CGSize maxLabelSize = tweeterNameLabel.frame.size;    
    CGSize labelSize = [tweet.nameString sizeWithFont:tweeterNameLabel.font 
                                    constrainedToSize:maxLabelSize 
                                        lineBreakMode:tweeterNameLabel.lineBreakMode]; 
    CGRect newScreenNameFrame = tweeterScreenNameLabel.frame;
    newScreenNameFrame.origin.x = 75.0f + labelSize.width;
    tweeterScreenNameLabel.frame = newScreenNameFrame;
    

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    UILabel *tweetTimeLabel = (UILabel *)[cell.contentView viewWithTag:102];
    tweetTimeLabel.text = [dateFormatter stringFromDate:tweet.createdAtDate];

    
    
    NSString *string = tweet.tweetTextString;
    CGSize maximumLabelSize = CGSizeMake( 200.0f, 9999.0f );
    CGSize expectedLabelSize = [string sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
    
    UILabel *tweetTextLabel = (UILabel *)[cell.contentView viewWithTag:103];
    tweetTextLabel.text = tweet.tweetTextString;
    CGRect newTweetFrame = tweetTextLabel.frame;
    newTweetFrame.size.height = expectedLabelSize.height;
    tweetTextLabel.frame = newTweetFrame;
    
    UILabel *retweetCountLabel = (UILabel *)[cell.contentView viewWithTag:104];
    
    if ( tweet.retweetCount == 1 ) 
        retweetCountLabel.text = [NSString stringWithFormat:@"%i Retweet", tweet.retweetCount];
    else 
        retweetCountLabel.text = [NSString stringWithFormat:@"%i Retweets", tweet.retweetCount];

    CGRect newRetweetFrame = retweetCountLabel.frame;
    newRetweetFrame.origin.y = expectedLabelSize.height + 30.0f;
    retweetCountLabel.frame = newRetweetFrame;
    
    UIImageView *retweetImageView = (UIImageView *)[cell.contentView viewWithTag:106];
    CGRect retweetImageViewFrame = retweetImageView.frame;
    retweetImageViewFrame.origin.y = expectedLabelSize.height + 35.0f;
    retweetImageView.frame = retweetImageViewFrame;
    
    UIButton *rtButton = (UIButton *)[cell.contentView viewWithTag:105];
    CGRect rtButtonNewFrame = rtButton.frame;
    rtButtonNewFrame.origin.y = expectedLabelSize.height + 30.0f;
    rtButton.frame = rtButtonNewFrame;
    
    UIImageView *logoImageView = (UIImageView *)[cell.contentView viewWithTag:99];
    logoImageView.image = self.pdLogoImage;
    
    if (tweet.urlEntityString.length > 0)
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

@end
