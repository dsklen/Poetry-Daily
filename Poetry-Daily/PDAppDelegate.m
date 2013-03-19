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
#import "PayPal.h"
#import "Appirater.h"
#import "NSDate+PDAdditions.h"
#import "PDMediaServer.h"
//#import "FlurryAnalytics.h"

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
        
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f]];
        
        [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0]];        
        [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0]];

        UIViewController *viewController1, *viewController2, *viewController3, *viewController4;
       
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
        {
            PDHomeViewController *home = [[PDHomeViewController alloc] initWithNibName:@"PDHomeViewController" bundle:nil];
            viewController1 = [[UINavigationController alloc] initWithRootViewController:home];                                       
            
            PDBrowseAllPoemsViewController *browse = [[PDBrowseAllPoemsViewController alloc] initWithNibName:@"PDBrowseAllPoemsViewController" bundle:nil];
            viewController2 = [[UINavigationController alloc] initWithRootViewController:browse];
            
            
            PDChooseNewsViewController *news = [[PDChooseNewsViewController alloc] initWithNibName:@"PDChooseNewsViewController" bundle:nil];
            viewController3 = [[UINavigationController alloc] initWithRootViewController:news];
            
            PDMoreViewController *more = [[PDMoreViewController alloc] initWithNibName:@"PDMoreViewController" bundle:nil];
            viewController4 = [[UINavigationController alloc] initWithRootViewController:more];
        } 
        else 
        {
            PDHomeViewController *home = [[PDHomeViewController alloc] initWithNibName:@"PDHomeViewController-iPad" bundle:nil];
            viewController1 = [[UINavigationController alloc] initWithRootViewController:home];
            
            PDBrowseAllPoemsViewController *browse = [[PDBrowseAllPoemsViewController alloc] initWithNibName:@"PDBrowseAllPoemsViewController" bundle:nil];
            viewController2 = [[UINavigationController alloc] initWithRootViewController:browse];
            
            
            PDChooseNewsViewController *news = [[PDChooseNewsViewController alloc] initWithNibName:@"PDChooseNewsViewController" bundle:nil];
            viewController3 = [[UINavigationController alloc] initWithRootViewController:news];
            
            PDMoreViewController *more = [[PDMoreViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController4 = [[UINavigationController alloc] initWithRootViewController:more];
        }
        
        
        self.tabBarController = [[UITabBarController alloc] init];
        self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, viewController4, nil];
        
    //    [self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tab_bg"]];
        
        [self.tabBarController.tabBar setSelectedImageTintColor:[UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f]];

        self.window.rootViewController = self.tabBarController;
        [self.window makeKeyAndVisible];
        

    }];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPoemForDay:) name:@"PDOpenPoemFromTweetNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTodaysPoem:) name:@"PDOpenTodaysPoemFromTweetNotification" object:nil];

    
    [Appirater setAppId:@"376587204"];
    [Appirater appLaunched:YES];
    
//    [FlurryAnalytics startSession:@"RCE71QKU7J9GWWHSN67D"];
    
    return YES;
    
    //You must call initializeWithAppID:forEnvironment: or initializeWithAppID: before performing any other
	//action with the library. You must supply your application ID, and you may specify the environment
	//by passing in ENV_LIVE (default), ENV_SANDBOX, or ENV_NONE (offline demo mode).
    [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
    
	
    //	[PayPal initializeWithAppID:@"your live app id" forEnvironment:ENV_LIVE];
	//[PayPal initializeWithAppID:@"anything" forEnvironment:ENV_NONE];
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


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

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
