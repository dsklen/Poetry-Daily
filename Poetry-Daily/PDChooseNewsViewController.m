//
//  PDChooseNewsViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 3/15/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDChooseNewsViewController.h"
#import "PDTwitterViewController.h"
#import "PDNewsViewController.h"
#import "SVWebViewController.h"
#import "PDMediaServer.h"
#import "SVProgressHUD.h"
#import "EmailSignUpViewController.h"

@interface PDChooseNewsViewController ()

//- (IBAction)changeNewsView:(id)sender;
- (IBAction)signUp:(id)sender;
@property (strong, nonatomic) UISegmentedControl *newsSegmentedControl;

@end

@implementation PDChooseNewsViewController

- (IBAction)news:(id)sender;
{
//    PDNewsViewController *news = [[PDNewsViewController alloc] init];
    
    SVWebViewController *web = [[SVWebViewController alloc] initWithAddress:@"http://poems.com/news_mobile.php"];
    web.navigationItem.hidesBackButton = YES;
    
    
    UISegmentedControl *newsSegmentedControler = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"News", @"Twitter", nil]];
    newsSegmentedControler.segmentedControlStyle = UISegmentedControlStyleBar;
    newsSegmentedControler.selectedSegmentIndex = 0;
    [newsSegmentedControler addTarget:self
                         action:@selector(newsViewShouldChange:)
               forControlEvents:UIControlEventValueChanged];
    web.navigationItem.titleView = newsSegmentedControler;
    self.newsSegmentedControl = newsSegmentedControler;
    
    
    [newsSegmentedControler setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0], UITextAttributeTextColor,
                                                             [UIColor whiteColor ], UITextAttributeTextShadowColor,
                                                             [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                             [UIFont boldSystemFontOfSize:13.0f], UITextAttributeFont,
                                                             nil] forState:UIControlStateNormal];
//    [newsSegmentedControler setTintColor:[UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f]];

    

//    [newsSegmentedControler setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_new"]]]; //[UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f]];
    
    
    UIBarButtonItem *showSignUp = [[UIBarButtonItem alloc] initWithTitle:@"Sign-up" style:UIBarButtonItemStyleBordered target:self action:@selector(signUp:)];
    web.navigationItem.rightBarButtonItem = showSignUp;

    
//    web.hidesBottomBarWhenPushed = YES;
    web.title = @"News";
    [web.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController pushViewController:web animated:YES];
    web.navigationController.toolbar.tintColor = [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0];

}

- (IBAction)signUp:(id)sender;
{
    EmailSignUpViewController *e_l = [[EmailSignUpViewController alloc] init];
    self.navigationController.navigationItem.hidesBackButton = NO;
	[super.navigationController pushViewController:e_l animated:YES];
    self.navigationController.navigationItem.hidesBackButton = NO;

}

- (IBAction)newsViewShouldChange:(id)sender;
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    
    if ( seg.selectedSegmentIndex == 0 )
    {
//        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self twitter:nil];
        
        seg.selectedSegmentIndex = 0;
    }
    
}

- (IBAction)twitter:(id)sender;
{
    PDTwitterViewController *twitter = [[PDTwitterViewController alloc] initWithNibName:@"PDTwitterViewController" bundle:nil];
    [self.navigationController pushViewController:twitter animated:NO];
}

-(IBAction)emailSignUpPressed:(id)sender;
{
//	EmailSignUpViewController *e_l = [[EmailSignUpViewController alloc] init];
//	[super.navigationController pushViewController:e_l animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Newsroom", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"23-bird"];
        
        NSDictionary *titleTextAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont boldSystemFontOfSize:10.0f], UITextAttributeFont,
                                                       [UIColor darkGrayColor], UITextAttributeTextColor,
                                                       nil];
        
        NSDictionary *titleTextHighlightedAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont boldSystemFontOfSize:10.0f], UITextAttributeFont,
                                                                  [UIColor whiteColor], UITextAttributeTextColor,
                                                                  nil];
        
        [self.tabBarItem setTitleTextAttributes:titleTextAttributesDictionary forState:UIControlStateNormal];
        [self.tabBarItem setTitleTextAttributes:titleTextHighlightedAttributesDictionary forState:UIControlStateSelected];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self news:nil];
}

- (void)viewDidAppear:(BOOL)animated;
{
    self.newsSegmentedControl.selectedSegmentIndex = 0;

    NSLog(@"VIEW DID APPEAR : CHOOSE");

}




@end
