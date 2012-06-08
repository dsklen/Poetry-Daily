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

@interface PDHomeViewController ()

@end

@implementation PDHomeViewController


#pragma mark - API

@synthesize currentPoem;
@synthesize poemPublishedDateLabel;
@synthesize poemTitleLabel;
@synthesize poemAuthorLabel;
@synthesize poemAuthorImageView;
@synthesize readPoemButton;

- (IBAction)showMainPoemView:(id)sender;
{
    PDMainPoemViewController *mainViewController = [[PDMainPoemViewController alloc] initWithNibName:@"PDMainPoemViewController" bundle:nil];
    
    NSLog(@"%@", self.currentPoem.poemBody);
    [self.navigationController pushViewController:mainViewController animated:YES];
    [mainViewController.webView loadHTMLString:self.currentPoem.poemBody baseURL:nil];
}

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Home", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"53-house"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightpaperfibers"]];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    
    self.poemAuthorImageView.image = [UIImage imageNamed:@"plumlystanley.jpeg"];
    self.poemAuthorImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.poemAuthorImageView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
    self.poemAuthorImageView.layer.shadowRadius = 2.0f;
    self.poemAuthorImageView.layer.shadowOpacity = 0.5f;  
    
    self.readPoemButton.layer.backgroundColor = [[UIColor lightGrayColor] CGColor];
    self.readPoemButton.layer.cornerRadius = 6.0f;
    self.readPoemButton.layer.borderWidth = 2.0f;
    self.readPoemButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    PDMediaServer *server = [[PDMediaServer alloc] init];
    
    NSString *poemID = [server poemIDFromDate:[NSDate date]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Poem"];
    
    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [serverInfo setObject:poemID forKey:PDPoemKey];
    [serverInfo setObject:[NSNumber numberWithInteger:PDServerCommandPoem] forKey:PDServerCommandKey];
    
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.poemID == %@", poemID];
    request.fetchLimit = 1;
    
    NSArray *items = [[PDCachedDataController sharedDataController] fetchObjects:request
                                                                      serverInfo:serverInfo 
                                                                cacheUpdateBlock:^(NSArray *newResults) {
                                                                
                                                                    PDPoem *poem = [newResults lastObject];
                                                                    
                                                                    if ( poem )
                                                                    {
                                                                        self.currentPoem = poem;
                                                                        self.poemTitleLabel.text = poem.title;
                                                                        self.poemAuthorLabel.text = [NSString stringWithFormat:@"By %@", poem.author];
                                                                    }
                                                                
                                                                }];

    PDPoem *poem = [items lastObject];
    
    if ( poem )
    {
        self.poemTitleLabel.text = poem.title;
        self.poemAuthorLabel.text = poem.author;
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated;
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated;
{
//    [SVProgressHUD showWithStatus:@"Fetching Poem"];
    [SVProgressHUD dismissWithSuccess:@"Found Poem"];
    //    [SVProgressHUD dismissWithError:@"Sike, not yet..." afterDelay:4.0f];
}

- (void)viewDidUnload
{
    [self setPoemPublishedDateLabel:nil];
    [self setPoemTitleLabel:nil];
    [self setPoemAuthorLabel:nil];
    [self setPoemAuthorImageView:nil];
    [self setReadPoemButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
