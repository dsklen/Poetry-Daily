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
    [super viewDidLoad];
    
    self.title = @"News";
    
    SVWebViewController *web = [[SVWebViewController alloc] init];
    web.view.frame = self.view.frame;

    [self.view addSubview:web.view];
    
}

@end
