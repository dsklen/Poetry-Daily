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


#pragma mark - Properties

@synthesize currentPoem = _currentPoem;
@synthesize poemPublishedDateLabel = _poemPublishedDateLabel;
@synthesize poemTitleLabel = poemTitleLabel;
@synthesize poemAuthorLabel = _poemAuthorLabel;
@synthesize poemAuthorImageView = _poemAuthorImageView;
@synthesize readPoemButton = _readPoemButton;


#pragma mark - API

- (IBAction)showMainPoemView:(id)sender;
{
    PDMainPoemViewController *mainViewController = [[PDMainPoemViewController alloc] initWithNibName:@"PDMainPoemViewController" bundle:nil];
    
    
    NSString *style = nil;

	if ([self.currentPoem.poemBody rangeOfString:@"<!--prose-->"].location == NSNotFound) {
		style = @"<html><head><style type=\"text/css\"> body {font-size: 40px; white-space:normal; padding:5px; margin:8px; width:800px;}</style></head><body>";
	}
	else {
		style = @"<html><head><style type=\"text/css\"> body {font-size: 40px; white-space:normal; padding:5px; margin:8px;width:800px;}</style></head><body>";
	}
	
	NSString *formatedHTML = [NSString stringWithFormat:@"%@%@%@", style, self.currentPoem.poemBody , @"</body></html>"];
    
    [self.navigationController pushViewController:mainViewController animated:YES];
    [mainViewController.webView loadHTMLString:formatedHTML baseURL:nil];
    
    NSString *newHtml = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = auto';"]; //  '%d%%';", 3000];
    [mainViewController.webView stringByEvaluatingJavaScriptFromString:newHtml];
}


#pragma mark - Private API

- (IBAction)fetchRandomPoem:(id)sender;
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching Poem...", @"Fetching Poem...")];
    
    PDMediaServer *server = [[PDMediaServer alloc] init];
    
    int randomInterval = arc4random() % 365 * 24 * 60 * 60 * -1;
    NSDate *randomDate = [NSDate dateWithTimeIntervalSinceNow:randomInterval];
    NSString *poemID = [server poemIDFromDate:randomDate];
    
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
                                                                        self.poemPublishedDateLabel.text = poem.journalTitle;
                                                                        
                                                                        [SVProgressHUD dismiss];

                                                                    }
                                                                    
                                                                }];
    
    PDPoem *poem = [items lastObject];
    
    if ( poem )
    {
        self.poemTitleLabel.text = poem.title;
        self.poemAuthorLabel.text = [NSString stringWithFormat:@"By %@", poem.author];
        self.poemPublishedDateLabel.text = poem.journalTitle;

        [SVProgressHUD dismiss];
    }

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
    
    self.poemAuthorImageView.image = [UIImage imageNamed:@"plumlystanley.jpeg"];
    self.poemAuthorImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.poemAuthorImageView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
    self.poemAuthorImageView.layer.shadowRadius = 2.0f;
    self.poemAuthorImageView.layer.shadowOpacity = 0.5f;  
    
    self.readPoemButton.layer.backgroundColor = [[UIColor lightGrayColor] CGColor];
    self.readPoemButton.layer.cornerRadius = 6.0f;
    self.readPoemButton.layer.borderWidth = 2.0f;
    self.readPoemButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching Poem...", @"Fetching Poem...")];
    
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
                                                                        
                                                                        [SVProgressHUD dismiss];
                                                                    }
                                                                
                                                                }];

    PDPoem *poem = [items lastObject];
    
    if ( poem )
    {
        self.poemTitleLabel.text = poem.title;
        self.poemAuthorLabel.text = [NSString stringWithFormat:@"By %@", poem.author];
        
        [SVProgressHUD dismiss];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(fetchRandomPoem:) 
                                                 name:@"DeviceShaken"
                                               object:nil];
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

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
