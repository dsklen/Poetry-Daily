//
//  PDHomeViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 5/24/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDHomeViewController.h"
#import "PDMainPoemViewController.h"
#import "PDCachedDataController.h"
#import "PDMediaServer.h"
#import "PDPoem.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "PDConstants.h"
#import "NSDate+PDAdditions.h"

@interface PDHomeViewController ()

- (void)showPoemForDay:(NSDate *)date;
- (void)swipePreviousDay:(UISwipeGestureRecognizer *)swipeGesture;
- (void)swipeNextDay:(UISwipeGestureRecognizer *)swipeGesture;
- (void)updatePoemInformationForPoem:(PDPoem *)poem animated:(BOOL)animated;

@end

@implementation PDHomeViewController


#pragma mark - Properties

@synthesize currentPoem = _currentPoem;
@synthesize poemPublishedDateLabel = _poemPublishedDateLabel;
@synthesize poemTitleLabel = poemTitleLabel;
@synthesize poemAuthorLabel = _poemAuthorLabel;
@synthesize poemAuthorImageView = _poemAuthorImageView;
@synthesize readPoemButton = _readPoemButton;
@synthesize showPreviousDayButton = _showPreviousDayButton;
@synthesize showNextDayButton = _showNextDayButton;


#pragma mark - API

- (IBAction)showMainPoemView:(id)sender;
{
    PDMainPoemViewController *mainViewController = [[PDMainPoemViewController alloc] initWithNibName:@"PDMainPoemViewController" bundle:nil];
     
    [self.navigationController pushViewController:mainViewController animated:YES];

    [mainViewController setCurrentPoem:self.currentPoem];
}


#pragma mark - Private API

- (void)showPoemForDay:(NSDate *)date;
{
    PDMediaServer *server = [[PDMediaServer alloc] init];
    NSString *poemID = [server poemIDFromDate:date];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Poem"];
    
    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [serverInfo setObject:poemID forKey:PDPoemKey];
    [serverInfo setObject:[NSNumber numberWithInteger:PDServerCommandPoem] forKey:PDServerCommandKey];
    
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.poemID == %@", poemID];
    request.fetchLimit = 1;
    
    NSArray *items = [[PDCachedDataController sharedDataController] fetchObjects:request serverInfo:serverInfo cacheUpdateBlock:^(NSArray *newResults) {
                                                                    
                PDPoem *poem = [newResults lastObject];
        
//                if ( ![self.currentPoem.poemID isEqualToString:poem.poemID] ) return;
        
                if ( poem )
                {
                    [self updatePoemInformationForPoem:poem animated:NO];
                    
                    _currentPoem = poem;
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                    self.poemPublishedDateLabel.text = [dateFormatter stringFromDate:poem.publishedDate];
                    
                    if ( poem.authorImageURLString.length > 0)
                    {
                        PDMediaServer *server = [[PDMediaServer alloc] init];
                        
                        [server fetchPoetImagesWithStrings:@[poem.authorImageURLString] block:^(NSArray *items, NSError *error) {
                            
                            if ( items && !error )
                            {
                                NSData *newImageData = items[0];
                                poem.authorImageData  = newImageData;
                                self.poemAuthorImageView.image = poem.authorImage;
                                
                                poem.hasAttemptedDownload = YES;
                            }
                            else
                            {
                                poem.hasAttemptedDownload = NO;
                            }
                            
                        }];
                    }   
                    
                    self.showNextDayButton.hidden = ( [date timeIntervalSinceDate:[NSDate charlottesvilleDate]] > -1000.0f  );         
                    self.todaysPoemLabel.hidden = !( [date timeIntervalSinceDate:[NSDate charlottesvilleDate]] > -1000.0f  );

                    [SVProgressHUD dismiss];
                }
         }];
    
    PDPoem *poem = [items lastObject];
    
    if ( poem )
    {
        [self updatePoemInformationForPoem:poem animated:YES];

        _currentPoem = poem;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        self.poemPublishedDateLabel.text = [dateFormatter stringFromDate:poem.publishedDate];

        self.poemAuthorImageView.image = poem.authorImage;

        self.showNextDayButton.hidden = ( [date timeIntervalSinceDate:[NSDate charlottesvilleDate]] > -1000.0f  );
        self.todaysPoemLabel.hidden = !( [date timeIntervalSinceDate:[NSDate charlottesvilleDate]] > -1000.0f  );
        
        if ( poem.title.length > 0 && poem.author.length > 0  )
            [SVProgressHUD dismiss];
        else
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching Poem...", @"Fetching Poem...")];


    }
}

- (IBAction)fetchRandomPoem:(id)sender;
{
    int randomInterval = arc4random() % 365 * 24 * 60 * 60 * -1;
    NSDate *randomDate = [NSDate dateWithTimeIntervalSinceNow:randomInterval];

    [self showPoemForDay:randomDate];
}

- (IBAction)showPreviousDay:(id)sender;
{
    NSDate *newDate = [self.currentPoem.publishedDate dateByAddingTimeInterval:-86400.0f];
    
    [self showPoemForDay:newDate];
}

- (void)swipePreviousDay:(UISwipeGestureRecognizer *)swipeGesture;
{
    NSDate *newDate = [self.currentPoem.publishedDate dateByAddingTimeInterval:-86400.0f];
    
    if ( [newDate timeIntervalSinceDate:[NSDate charlottesvilleDate]] > -1000.0f )
        return;
    
    [self showPoemForDay:newDate];
}

- (IBAction)showNextDay:(id)sender;
{
    NSDate *newDate = [self.currentPoem.publishedDate dateByAddingTimeInterval:86400.0f];
        
    [self showPoemForDay:newDate];
}

- (void)swipeNextDay:(UISwipeGestureRecognizer *)swipeGesture;
{
    NSDate *newDate = [self.currentPoem.publishedDate dateByAddingTimeInterval:86400.0f];
    
    if ( [newDate timeIntervalSinceDate:[NSDate charlottesvilleDate]] > -1000.0f )
        return;
    
    [self showPoemForDay:newDate];
}

- (void)updatePoemInformationForPoem:(PDPoem *)poem animated:(BOOL)animated;
{
    NSMutableString *HTML = [[NSMutableString alloc ] init];
   
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [HTML appendString:[NSString stringWithFormat:@"<html><head><style type=\"text/css\"> body {font-family:helvetica,sans-serif; font-size: 16px;  white-space:normal; padding:0px; margin:0px;}</style></head><body>"]];
    }
    else
    {
        [HTML appendString:[NSString stringWithFormat:@"<html><head><style type=\"text/css\"> body {font-family:helvetica,sans-serif; font-size: 24px;  white-space:normal; padding:0px; margin:0px;}</style></head><body>"]];

    }
    
    
    [HTML appendString:[NSString stringWithFormat:@"<h3>%@</h3>", poem.title]];
    [HTML appendString:[NSString stringWithFormat:@"By %@", poem.author]];
   
    if ( poem.journalTitle.length > 0 )
        [HTML appendString:[NSString stringWithFormat:@"<br>from <i>%@</i> ", poem.journalTitle]];
    
    [HTML appendString:@"</body></html>"];
    
    
    NSString *oldHTML = [self.poemInformationWebView stringByEvaluatingJavaScriptFromString:
                      @"document.body.innerHTML"];
    
    if ( poem.journalTitle.length == 0 )
    {
        [self.poemInformationWebView loadHTMLString:HTML baseURL:nil];

        return;
    }
    
    NSLog( @"animated: %@", animated ? @"YES" : @"NO");
    
    if ( YES ) //[oldHTML rangeOfString:poem.journalTitle].location != NSNotFound )
    {
        [UIView animateWithDuration:animated ? 0.2f : 0.0f animations:^{
          
            self.poemInformationWebView.alpha  = 1.0f;
            self.poemInformationWebView.alpha  = 0.0f;

        } completion:^(BOOL finished) {
         
            [self.poemInformationWebView loadHTMLString:HTML baseURL:nil];

            [UIView animateWithDuration:0.3f animations:^{
                
                self.poemInformationWebView.alpha  = 0.0f;
                self.poemInformationWebView.alpha  = 1.0f;
                
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    else
    {
        [self.poemInformationWebView loadHTMLString:HTML baseURL:nil];
    }

    NSString *resize = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = auto';"]; //  '%d%%';", 3000];
    [self.poemInformationWebView stringByEvaluatingJavaScriptFromString:resize];
}


#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Home", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"53-house"];
        
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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightpaperfibers"]];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PDLogo.png"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.frame = CGRectMake(0.0f, 0.0f, 100.0f, 42.0f);
    self.navigationItem.titleView = logoImageView;    
    
    self.poemAuthorImageView.image = [UIImage imageNamed:@"plumlystanley.jpeg"];
    self.poemAuthorImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.poemAuthorImageView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
    self.poemAuthorImageView.layer.shadowRadius = 2.0f;
    self.poemAuthorImageView.layer.shadowOpacity = 0.5f;  
    
    self.readPoemButton.layer.backgroundColor = [[UIColor lightGrayColor] CGColor];
    self.readPoemButton.layer.cornerRadius = 6.0f;
    self.readPoemButton.layer.borderWidth = 2.0f;
    self.readPoemButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    [self showPoemForDay:[NSDate charlottesvilleDate]];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(fetchRandomPoem:) 
                                                 name:@"DeviceShaken"
                                               object:nil];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNextDay:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.poemPublishedDateLabel addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePreviousDay:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.poemPublishedDateLabel addGestureRecognizer:swipeRight];
}

- (void)viewWillAppear:(BOOL)animated;
{
    self.navigationController.navigationBarHidden = NO;
    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setPoemPublishedDateLabel:nil];
    [self setPoemTitleLabel:nil];
    [self setPoemAuthorLabel:nil];
    [self setPoemAuthorImageView:nil];
    [self setReadPoemButton:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"DeviceShaken"
                                                  object:nil];

    [self setShowPreviousDayButton:nil];
    [self setShowNextDayButton:nil];
    [self setTodaysPoemLabel:nil];
    [self setPoemInformationWebView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
