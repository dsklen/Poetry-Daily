//
//  EmailSignUpViewController.m
//  PD3
//
//  Created by David Sklenar on 2/3/10.
//  Copyright 2010 University of Virginia. All rights reserved.
//

#import "EmailSignUpViewController.h"


@implementation EmailSignUpViewController
@synthesize emailAddressField, webView, email, success, failure;

BOOL submitted = NO;
BOOL shown = NO;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	[emailAddressField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	self.email = [NSString stringWithFormat:@"\"%@\"", textField.text];

	[textField resignFirstResponder];
	
    return NO;
}

- (IBAction)submitEmail;
{
	submitted = NO;
	shown = NO;
		NSString *html = [NSString stringWithFormat:@"<div class=\"subscribe_form\"> <form id=\"myform\" action=\"http://comet.sparklist.com/scripts/submany.pl\" method=post> <input type=text name=email size=20 value=%@> <input type=hidden name=\"list\" Value=\"join-poetrydaily@comet.sparklist.com\"> <br><input type=\"submit\" value=\"Subscribe\"> </form></div>", self.email];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)webView:(UIWebView *)web didFailLoadWithError:(NSError *)error;
{	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error: Failed to connect to server." message:@"Make sure you are connected to the internet in order to submit your e-mail" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];	
	[av show];	
}

- (void)webViewDidFinishLoad:(UIWebView *)web;
{
	NSString *newHtml = [web stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

	BOOL sent = !([newHtml rangeOfString:@"Thank you"].location == NSNotFound);
	
    if ( submitted == NO )
    {
		[web stringByEvaluatingJavaScriptFromString:@"document.forms[\"myform\"].submit();"];
		submitted = YES;
	}
	else
    {
		if (sent)
        {
			UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Thanks" message:@"Please check your email in order to confirm your subscription." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];	
			[av show];
			[self.navigationController popViewControllerAnimated:YES];
		}
		else if (!sent && !shown)
        {
			UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You have not entered a valid email address. Please try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];	
			[av show];
			shown = YES;
		}
	}
}

- (void)viewDidLoad;
{
	self.navigationController.navigationItem.title = @"Welcome!";

	self.success.hidden = YES;
	self.failure.hidden = YES;
	self.webView.hidden = YES;
	self.failure.text = @"Sorry, but you have not entered a valid email address. Please try again.";
	[self.webView setDelegate:self];
	
    self.navigationController.navigationItem.hidesBackButton = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(popViewControllerAnimated:)];
   
    [super viewDidLoad];

}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
