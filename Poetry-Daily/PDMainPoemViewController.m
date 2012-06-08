//
//  PDMainPoemViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 5/24/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDMainPoemViewController.h"
#import "SVProgressHUD.h"

@interface PDMainPoemViewController ()

@end

@implementation PDMainPoemViewController
@synthesize containerScrollView;
@synthesize navigationBar;
@synthesize webView;


#pragma mark - API

- (IBAction)returnToHomeView:(id)sender;
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    
    CGSize newSize = self.containerScrollView.contentSize;
    newSize.height += 244.0f;
    self.containerScrollView.contentSize = CGSizeMake(320.0f, 500.0f);
}

- (void)viewDidUnload
{
    [self setContainerScrollView:nil];
    [self setNavigationBar:nil];
    [self setWebView:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
