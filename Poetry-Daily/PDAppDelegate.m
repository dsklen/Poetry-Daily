//
//  PDAppDelegate.m
//  Poetry-Daily
//
//  Created by David Sklenar on 4/10/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDAppDelegate.h"
#import "PDWindow.h"
#import "PDCachedDataController.h"
#import "PDHomeViewController.h"
#import "PDFavoritesViewController.h"
#import "PDBrowseAllPoemsViewController.h"
#import "PDTwitterViewController.h"
#import "PDMoreViewController.h"
#import "PDChooseNewsViewController.h"
#import "Appirater.h"
#import "NSDate+PDAdditions.h"
#import "PDMediaServer.h"
#import "PDNewsViewController.h"
#import "PDTwitterViewController.h"
//#import "FlurryAnalytics.h"
#import "ISRevealController.h"

@implementation PDAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    PDCachedDataController *controller = [PDCachedDataController sharedDataController];
    
    [controller load:^(BOOL success, NSError *error) {
        
        if ( !success )
        {
            NSLog( @"Could not load cache, delete the Core Data store and try again. (%@)", [error localizedDescription] );
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not load local database. Delete app completely, and reinstall from TestFlight." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            
            [alert show];
            
            return;
        }
        
        self.window = [[PDWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
       
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0], UITextAttributeTextColor,
          [UIColor whiteColor], UITextAttributeTextShadowColor,
          [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
            [UIFont boldSystemFontOfSize:18.0f], UITextAttributeFont,
          nil]];
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0]];

        
        [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0], UITextAttributeTextColor,
                                                                       [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                                       [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                                       [UIFont boldSystemFontOfSize:13.0f], UITextAttributeFont,
                                                                       nil] forState:UIControlStateNormal];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0], UITextAttributeTextColor,
                                                              [UIColor whiteColor ], UITextAttributeTextShadowColor,
                                                              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                              [UIFont boldSystemFontOfSize:13.0f], UITextAttributeFont,
                                                              nil] forState:UIControlStateNormal];
        
        [[UISegmentedControl appearanceWhenContainedIn:[PDTwitterViewController class], [UINavigationBar class], [PDChooseNewsViewController class], nil] setTintColor:[UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f]];

        
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f]];
        
        [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0]];        
        [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0]];

        UIViewController *viewController1, *viewController2, *viewController3, *viewController4;
       
        if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ) 
        {
            PDHomeViewController *home = [[PDHomeViewController alloc] initWithNibName:@"PDHomeViewController" bundle:nil];
            viewController1 = [[UINavigationController alloc] initWithRootViewController:home];                                       
            
            PDBrowseAllPoemsViewController *browse = [[PDBrowseAllPoemsViewController alloc] initWithNibName:@"PDBrowseAllPoemsViewController" bundle:nil];
            viewController2 = [[UINavigationController alloc] initWithRootViewController:browse];
            
            
            PDChooseNewsViewController *news = [[PDChooseNewsViewController alloc] initWithNibName:@"PDChooseNewsViewController" bundle:nil];
            viewController3 = [[UINavigationController alloc] initWithRootViewController:news];
            
            PDMoreViewController *more = [[PDMoreViewController alloc] initWithNibName:@"PDMoreViewController" bundle:nil];
            viewController4 = [[UINavigationController alloc] initWithRootViewController:more];
            
            self.tabBarController = [[UITabBarController alloc] init];
            self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, viewController4, nil];
            [self.tabBarController.tabBar setSelectedImageTintColor:[UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f]];
            
            self.window.rootViewController = self.tabBarController;
        } 
        else
        {
            
            PDHomeViewController *rootViewController = [[PDHomeViewController alloc] initWithNibName:@"PDHomeViewController-iPad" bundle:nil];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
            
            PDBrowseAllPoemsViewController *nav = [[PDBrowseAllPoemsViewController alloc] initWithNibName:@"PDBrowseAllPoemsViewController" bundle:nil];
            UINavigationController *navItems = [[UINavigationController alloc] initWithRootViewController:nav];

            
            CGRect newFrame = navItems.view.frame;
            newFrame.size.width = 500.0f;
            navItems.view.frame = newFrame;
            
            
            ISRevealController *revealController = [[ISRevealController alloc] initWithFrontViewController:navigationController rearViewController:navItems];
            
            self.revealViewController = revealController;

            self.window.rootViewController = self.revealViewController;
        }
        
        [self.window makeKeyAndVisible];
    }];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPoemForDay:) name:@"PDOpenPoemFromTweetNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTodaysPoem:) name:@"PDOpenTodaysPoemFromTweetNotification" object:nil];

    [Appirater setAppId:@"376587204"];
    [Appirater appLaunched:YES];
    
//    [FlurryAnalytics startSession:@"RCE71QKU7J9GWWHSN67D"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
    self.tabBarController.selectedIndex = 0;

    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:0];
    [nav popToRootViewControllerAnimated:NO];
    PDHomeViewController *home = (PDHomeViewController *)[nav topViewController];
    PDMediaServer *server = [[PDMediaServer alloc] init];
    NSDate *poemDate = [server dateFromPoemID:[[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [home showPoemForDay:poemDate];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}


// Navigate to a specific poem.

- (void)showPoemForDay:(NSNotification *)aNotification;
{
    self.tabBarController.selectedIndex = 0;
    
    NSString *poemID = [aNotification object];
    
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:0];
    [nav popToRootViewControllerAnimated:NO];
    PDHomeViewController *home = (PDHomeViewController *)[nav topViewController];
    PDMediaServer *server = [[PDMediaServer alloc] init];
    NSDate *poemDate = [server dateFromPoemID:poemID];

    [home showPoemForDay:poemDate];
}

- (void)showTodaysPoem:(NSNotification *)aNotification;
{
    self.tabBarController.selectedIndex = 0;
    
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:0];
    [nav popToRootViewControllerAnimated:NO];
    PDHomeViewController *home = (PDHomeViewController *)[nav topViewController];
    [home showPoemForDay:[NSDate charlottesvilleDate]];
}

@end
