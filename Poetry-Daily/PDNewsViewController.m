//
//  PDNewsViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 3/15/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDNewsViewController.h"
#import "SVProgressHUD.h"
#import "SVWebViewController.h"


@interface PDNewsViewController ()

@end

@implementation PDNewsViewController

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

}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidLoad];
    
    self.title = @"News";
    
    SVWebViewController *web = [[SVWebViewController alloc] initWithAddress:@"http://poems.com/news_mobile.php"];
    
    web.view.frame = self.view.frame;
    
    web.hidesBottomBarWhenPushed = YES;
    web.title = @"News";
    //    web.mainWebView.scalesPageToFit = YES;
    [self.view addSubview:web.view];
    web.navigationController.toolbar.tintColor = [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0];
    
    [web.navigationController setToolbarHidden:YES animated:YES];
}

@end
