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

@end

@implementation PDChooseNewsViewController

- (IBAction)news:(id)sender;
{
//    PDNewsViewController *news = [[PDNewsViewController alloc] init];
    
    SVWebViewController *web = [[SVWebViewController alloc] initWithAddress:@"http://poems.com/news_mobile.php"];

    web.hidesBottomBarWhenPushed = YES;
    web.title = @"News";
//    web.mainWebView.scalesPageToFit = YES;
    [self.navigationController pushViewController:web animated:YES];
    web.navigationController.toolbar.tintColor = [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0];

    
//    [SVProgressHUD showWithStatus:@"Loading News..."];
//    
//    PDMediaServer *server = [[PDMediaServer alloc] init];
//
//    [server fetchNewsHTML:^(NSString *HTML, NSError *error) {
//       
//        if ( HTML && !error )
//        {
//            [web.mainWebView loadHTMLString:HTML baseURL:nil];
//            
//            [SVProgressHUD dismiss];
//        }
//        else
//            [SVProgressHUD dismissWithError:@"Failed"];
//        
//    }];
}

- (IBAction)twitter:(id)sender;
{
    PDTwitterViewController *twitter = [[PDTwitterViewController alloc] initWithNibName:@"PDTwitterViewController" bundle:nil];
    [self.navigationController pushViewController:twitter animated:YES];
}

-(IBAction)emailSignUpPressed:(id)sender;
{
	EmailSignUpViewController *e_l = [[EmailSignUpViewController alloc] init];
	[super.navigationController pushViewController:e_l animated:YES];
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
                                                                  [UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f], UITextAttributeTextColor,
                                                                  nil];
        
        [self.tabBarItem setTitleTextAttributes:titleTextAttributesDictionary forState:UIControlStateNormal];
        [self.tabBarItem setTitleTextAttributes:titleTextHighlightedAttributesDictionary forState:UIControlStateSelected];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

}




@end
