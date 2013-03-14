//
//  PDAboutPDViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 3/5/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDAboutPDViewController.h"

@interface PDAboutPDViewController ()

@end

@implementation PDAboutPDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"About";
    
    self.aboutPDWebView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light_honeycomb"]];

    NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
	[self.aboutPDWebView loadHTMLString:html baseURL:baseURL];
}

- (void)viewDidUnload {
    [self setAboutPDWebView:nil];
    [super viewDidUnload];
}
@end
