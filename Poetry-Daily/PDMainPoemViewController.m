//
//  PDMainPoemViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 5/24/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDMainPoemViewController.h"
#import "SVProgressHUD.h"
#import "PDMediaServer.h"
#import "PDCachedDataController.h"
#import <CoreData/CoreData.h>
#import "PDPoem.h"
#import "PDConstants.h"

@interface PDMainPoemViewController ()

- (void)share:(id)sender;

@end

@implementation PDMainPoemViewController
@synthesize containerScrollView;
@synthesize navigationBar;
@synthesize webView;

- (void)setCurrentPoem:(PDPoem *)currentPoem;
{
    _currentPoem = currentPoem;
    
    self.title = currentPoem.title;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Poem"];
    
    NSString *poemID = currentPoem.poemID;
    
    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [serverInfo setObject:poemID forKey:PDPoemKey];
    
    if ( currentPoem.poemBody.length == 0 )
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching Poem...", @"Fetching Poem...")];

        [serverInfo setObject:[NSNumber numberWithInteger:PDServerCommandPoem] forKey:PDServerCommandKey];
    }
    else
        [serverInfo setObject:[NSNumber numberWithInteger:PDServerCommandNone] forKey:PDServerCommandKey];
    
    
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.poemID == %@", currentPoem.poemID];
    request.fetchLimit = 1;
    
    NSArray *items = [[PDCachedDataController sharedDataController] fetchObjects:request serverInfo:serverInfo cacheUpdateBlock:^(NSArray *newResults) {
        
        PDPoem *poem = [newResults lastObject];
        
        if ( poem )
        {
            self.title = poem.title;
         
            _currentPoem = poem;
            
            NSString *style = nil;
            
            if ([currentPoem.poemBody rangeOfString:@"<!--prose-->"].location == NSNotFound) {
                style = @"<html><head><style type=\"text/css\"> body {font-size: 44px; white-space:normal; padding:15px; margin:8px; width:700px;}</style></head><body>";
            }
            else {
                style = @"<html><head><style type=\"text/css\"> body {font-size: 44px; white-space:normal; padding:15px; margin:8px;width:700px;}</style></head><body>";
            }
            
            NSString *loadingStyle =  @"<html><head><style type=\"text/css\"> body {font-size: 484px; white-space:normal; padding:15px; margin:8px;width:100px;}</style></head><body>";
            
            NSString *formatedHTML = [NSString stringWithFormat:@"%@%@%@", ( currentPoem.poemBody.length > 0 ) ? style : loadingStyle, ( currentPoem.poemBody.length > 0 ) ? currentPoem.poemBody : @"Loading..."  , @"</body></html>"];
            
            
            [self.webView loadHTMLString:formatedHTML baseURL:nil];
            NSString *newHtml = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = auto';"]; //  '%d%%';", 3000];
            [self.webView stringByEvaluatingJavaScriptFromString:newHtml];
            
            self.poemTitleLabel.text = poem.title;
            self.poemAuthorLabel.text = [NSString stringWithFormat:@"By %@", poem.author];
            
            if ( currentPoem.poemBody.length > 0 )
                [SVProgressHUD dismiss];
        }
    }];
    
    PDPoem *poem = [items lastObject];
    
    if ( poem )
    {
        self.title = currentPoem.title;

        _currentPoem = poem;

        NSString *style = nil;
        
        if ([currentPoem.poemBody rangeOfString:@"<!--prose-->"].location == NSNotFound) {
            style = @"<html><head><style type=\"text/css\"> body {font-size: 40px; white-space:normal; padding:5px; margin:8px; width:800px;}</style></head><body>";
        }
        else {
            style = @"<html><head><style type=\"text/css\"> body {font-size: 40px; white-space:normal; padding:5px; margin:8px;width:800px;}</style></head><body>";
        }
        
        NSString *formatedHTML = [NSString stringWithFormat:@"%@%@%@", style, ( currentPoem.poemBody.length > 0 ) ? currentPoem.poemBody : @"Loading..."  , @"</body></html>"];        
        
        [self.webView loadHTMLString:formatedHTML baseURL:nil];
        NSString *newHtml = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = auto';"]; //  '%d%%';", 3000];
        [self.webView stringByEvaluatingJavaScriptFromString:newHtml];
        
        self.poemTitleLabel.text = poem.title;
        self.poemAuthorLabel.text = [NSString stringWithFormat:@"By %@", poem.author];
        
        [SVProgressHUD dismiss];
    }
}

#pragma mark - API

- (IBAction)returnToHomeView:(id)sender;
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)share:(id)sender;
{
    NSString *textToShare = [NSString stringWithFormat:@"Poetry Daily: %@", self.currentPoem.title];
    UIImage *imageToShare = [UIImage imageNamed:@"logo@2x"];
    NSURL *urlToShare = [NSURL URLWithString:[NSString stringWithFormat:@"http://poems.com/poem.php?date=%@", self.currentPoem.poemID]];
    NSArray *activityItems = @[textToShare, imageToShare, urlToShare];
                         
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    share.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToWeibo];
    
    [self presentViewController:share animated:YES completion:^{}];
    
}
#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    
    CGSize newSize = self.containerScrollView.contentSize;
    newSize.height += 244.0f;
    self.containerScrollView.contentSize = CGSizeMake(320.0f, 500.0f);
    
    self.navigationItem.titleView = self.titleView;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
}

- (void)viewDidAppear:(BOOL)animated;
{
  //  [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated;
{
  //  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidUnload
{
    
    [self setContainerScrollView:nil];
    [self setNavigationBar:nil];
    [self setWebView:nil];
    [self setTitleView:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
