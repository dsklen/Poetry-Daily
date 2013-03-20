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

#import <MessageUI/MFMailComposeViewController.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


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
//        [SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching Poem...", @"Fetching Poem...")];

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
                style = @"<html><head><style type=\"text/css\"> body {font-size: 44px; white-space:nowrap; padding:15px; margin:8px; width:1300;}</style></head><body>";
            }
            else {
                style = @"<html><head><style type=\"text/css\"> body {font-size: 44px; white-space:nowrap; padding:15px; margin:8px;width:1300;}</style></head><body>";
            }
                    
            if ( currentPoem.poemBody.length > 0 )
                [SVProgressHUD showWithStatus:NSLocalizedString( @"Loading...", @"" )];
                        
            
            NSMutableString *formattedHTML = [[NSMutableString alloc]initWithCapacity:1000];
            [formattedHTML appendString:[NSMutableString stringWithFormat:@"%@%@", style, ( currentPoem.poemBody.length > 0 ) ? currentPoem.poemBody : @""]];
            [formattedHTML appendString:@"<a href=\"/\"><img src=\"lvl2_logo.gif\" alt=\"Poetry Daily\" border=\"0\" height=\"50\" width=\"62.5\" align=\"middle\" style=\"display:block;margin-left: auto;margin-right:auto;\"/></a><div id=\"content_footer\"><div class=\"beige_divider\"></div><div id=\"lvl2_logo\"></div></div><div class=\"clear_both\"></div></div></div><div id=\"page_copyright\" align=\"middle\" hspace=\"480\" style=\"font-size:12;\">Copyright © 1997-2013.  All rights reserved. </div></body></html>"];
            
            
            [self.webView loadHTMLString:formattedHTML baseURL:nil];
            NSString *newHtml = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '300'; document.body.style.width = 1300"]; //  '%d%%';", 3000];
            [self.webView stringByEvaluatingJavaScriptFromString:newHtml];
            self.webView.scalesPageToFit = NO;
            
            //            [SVProgressHUD dismiss];

            self.poemTitleLabel.text = poem.title;
            
            
            if ( self.currentPoem.isFavorite.boolValue )
                self.poemTitleLabel.text = [NSString stringWithFormat:@"★ %@", self.currentPoem.title];
            else
                self.poemTitleLabel.text = [NSString stringWithFormat:@"%@", self.currentPoem.title];
            
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
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {        
            if ([currentPoem.poemBody rangeOfString:@"<!--prose-->"].location == NSNotFound) {
                style = @"<html><head><style type=\"text/css\"> body {font-size: 50px; white-space:pre; padding:5px; margin:8px; width:800px;}</style></head><body>";
            }
            else {
                style = @"<html><head><style type=\"text/css\"> body {font-size: 50px; white-space:pre; padding:5px; margin:8px;width:800px;}</style></head><body>";
            }
            
            NSMutableString *formattedHTML = [[NSMutableString alloc]initWithCapacity:1000];
            [formattedHTML appendString:[NSMutableString stringWithFormat:@"%@%@", style, ( currentPoem.poemBody.length > 0 ) ? currentPoem.poemBody : @""]];
            [formattedHTML appendString:@"<a href=\"/\"><img src=\"lvl2_logo.gif\" alt=\"Poetry Daily\" border=\"0\" height=\"50\" width=\"62.5\" align=\"middle\" style=\"display:block;margin-left: auto;margin-right:auto;\"/></a><div id=\"content_footer\"><div class=\"beige_divider\"></div><div id=\"lvl2_logo\"></div></div><div class=\"clear_both\"></div></div></div><div id=\"page_copyright\" align=\"middle\" hspace=\"480\" style=\"font-size:12;\">Copyright © 1997-2013.  All rights reserved. </div></body></html>"];
            
            NSLog(@"%@", formattedHTML);
            
            [self.webView loadHTMLString:formattedHTML baseURL:nil];
            
            NSString *newHtml = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = auto';"]; //  '%d%%';", 3000];
            [self.webView stringByEvaluatingJavaScriptFromString:newHtml];
        }
        else
        {
            if ([currentPoem.poemBody rangeOfString:@"<!--prose-->"].location == NSNotFound) {
                style = @"<html><head><style type=\"text/css\"> body {font-size: 15px; white-space:pre; padding:30px; margin:8px; width:800px;}</style></head><body>";
            }
            else {
                style = @"<html><head><style type=\"text/css\"> body {font-size: 15px; white-space:pre; padding:30px; margin:8px;width:800px;}</style></head><body>";
            }
            
            NSMutableString *formattedHTML = [[NSMutableString alloc]initWithCapacity:1000];
            [formattedHTML appendString:[NSMutableString stringWithFormat:@"%@%@", style, ( currentPoem.poemBody.length > 0 ) ? currentPoem.poemBody : @""]];
            [formattedHTML appendString:@"<a href=\"/\"><img src=\"lvl2_logo.gif\" alt=\"Poetry Daily\" border=\"0\" height=\"50\" width=\"62.5\" align=\"middle\" style=\"display:block;margin-left: auto;margin-right:auto;\"/></a><div id=\"content_footer\"><div class=\"beige_divider\"></div><div id=\"lvl2_logo\"></div></div><div class=\"clear_both\"></div></div></div><div id=\"page_copyright\" align=\"middle\" hspace=\"480\" style=\"font-size:12;\">Copyright © 1997-2013.  All rights reserved. </div></body></html>"];
            
            NSLog(@"%@", formattedHTML);
            
            [self.webView loadHTMLString:formattedHTML baseURL:nil];

            
            NSString *newHtml = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = 15';"]; //  '%d%%';", 3000];
            [self.webView stringByEvaluatingJavaScriptFromString:newHtml];
        }
    
        if ( currentPoem.poemBody.length == 0 )
            [SVProgressHUD showWithStatus:NSLocalizedString( @"Loading", @"" )];
        

        if ( self.currentPoem.isFavorite.boolValue )
        {
            self.poemTitleLabel.text = [NSString stringWithFormat:@"★ %@", poem.title];
        }
        else
        {
            self.poemTitleLabel.text = poem.title;
        }
        
        self.poemAuthorLabel.text = [NSString stringWithFormat:@"By %@", poem.author];
        
        if ( currentPoem.poemBody.length > 0 )
            [SVProgressHUD dismiss];
    }
}

#pragma mark - API

- (IBAction)returnToHomeView:(id)sender;
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)action:(id)sender;
{
    UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:self.currentPoem.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", (self.currentPoem.isFavorite.boolValue) ? @"☆ Unfavorite" : @"★ Favorite", nil];
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [alert showInView:self.view];
    }
    else
    {
        [alert showFromBarButtonItem:sender animated:YES];
    }
}

- (void)share:(id)sender;
{
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") )
    {
        NSString *textToShare = [NSString stringWithFormat:@"Poetry Daily: %@", self.currentPoem.title];
        UIImage *imageToShare = [UIImage imageNamed:@"logo@2x"];
        
        NSString *poemID = self.currentPoem.poemID;
        NSString *urlString = [NSString stringWithFormat:@"http://poems.com/poem.php?date=%@", poemID, nil];
        NSURL *urlToShare = [NSURL URLWithString:urlString];
        
        NSString *textPlaceHolderToShare = [NSString stringWithFormat:@"Have the app? Tap Here:"];
        NSString *textPlaceHolder2ToShare = [NSString stringWithFormat:@"Have the app? Tap Here:"];

        
        NSString *urlSchemeString = [NSString stringWithFormat:@"poem://%@", poemID, nil];
        NSURL *urlSchemeToShare = [NSURL URLWithString:urlSchemeString];

        NSArray *activityItems = @[textToShare, imageToShare, urlToShare,textPlaceHolderToShare, textPlaceHolder2ToShare, urlSchemeToShare];
        
        UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        
        share.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToWeibo];
        
        [self presentViewController:share animated:YES completion:^{}];
    }
    else
    {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        
        controller.mailComposeDelegate = self;
        [controller setSubject:[NSString stringWithFormat:@"Poetry Daily: %@", self.currentPoem.title]];
        [controller setMessageBody:[NSString stringWithFormat:@"http://poems.com/poem.php?date=%@ <br> <br> Have the app? Open here: poem://%@ <br> <br> Sent from Poetry Daily for iPhone and iPad", self.currentPoem.poemID, self.currentPoem.poemID, nil] isHTML:YES];
        
        if ( controller )
            [self presentModalViewController:controller animated:YES];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    if ( result == MFMailComposeResultSent )
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString( @"Sent", @"" )];
    else if ( result == MFMailComposeResultFailed )
        [SVProgressHUD dismissWithError:NSLocalizedString( @"Failed to send", @"" ) afterDelay:0.0f];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    
    if ( buttonIndex == 0 )
        [self share:nil];
    if ( buttonIndex == 1 )
    {
        if ( self.currentPoem.isFavorite.boolValue )
        {
            self.currentPoem.isFavorite = [NSNumber numberWithBool:NO];
        
            [SVProgressHUD show];
            [SVProgressHUD dismissWithError:NSLocalizedString( @"Unfavorited", @"" ) ];
            
            self.poemTitleLabel.text = [NSString stringWithFormat:@"%@", self.currentPoem.title];
        }
        else
        {
            self.currentPoem.isFavorite = [NSNumber numberWithBool:YES];
        
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString( @"Favorited", @"" )];
            
            self.poemTitleLabel.text = [NSString stringWithFormat:@"★ %@", self.currentPoem.title];
        }
    }
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
    
    self.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    
    CGSize newSize = self.containerScrollView.contentSize;
    newSize.height += 244.0f;
    self.containerScrollView.contentSize = CGSizeMake(320.0f, 500.0f);
    
    self.navigationItem.titleView = self.titleView;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0], UITextAttributeTextColor,
                                                                   nil] forState:UIControlStateNormal];

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
