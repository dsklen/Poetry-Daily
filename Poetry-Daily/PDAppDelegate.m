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
#import "PayPal.h"
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
            return;
        }
        
        self.window = [[PDWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
       
        // Override point for customization after application launch.
       
        UIViewController *viewController1, *viewController2, *viewController3, *viewController4;
       
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
        {
            PDHomeViewController *home = [[PDHomeViewController alloc] initWithNibName:@"PDHomeViewController" bundle:nil];
            viewController1 = [[UINavigationController alloc] initWithRootViewController:home];                                       
            
            PDBrowseAllPoemsViewController *browse = [[PDBrowseAllPoemsViewController alloc] initWithNibName:@"PDBrowseAllPoemsViewController" bundle:nil];
            viewController2 = [[UINavigationController alloc] initWithRootViewController:browse];
            
            
            PDTwitterViewController *twitter = [[PDTwitterViewController alloc] initWithNibName:@"PDTwitterViewController" bundle:nil];
            viewController3 = [[UINavigationController alloc] initWithRootViewController:twitter]; 
            
            PDMoreViewController *more = [[PDMoreViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController4 = [[UINavigationController alloc] initWithRootViewController:more];
        } 
        else 
        {
            PDHomeViewController *home = [[PDHomeViewController alloc] initWithNibName:@"PDHomeViewController-iPad" bundle:nil];
            viewController1 = [[UINavigationController alloc] initWithRootViewController:home];
            
            PDBrowseAllPoemsViewController *browse = [[PDBrowseAllPoemsViewController alloc] initWithNibName:@"PDBrowseAllPoemsViewController" bundle:nil];
            viewController2 = [[UINavigationController alloc] initWithRootViewController:browse];
            
            
            PDTwitterViewController *twitter = [[PDTwitterViewController alloc] initWithNibName:@"PDTwitterViewController" bundle:nil];
            viewController3 = [[UINavigationController alloc] initWithRootViewController:twitter];
            
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
    
//    [FlurryAnalytics startSession:@"RCE71QKU7J9GWWHSN67D"];
    
    return YES;
    
    //You must call initializeWithAppID:forEnvironment: or initializeWithAppID: before performing any other
	//action with the library. You must supply your application ID, and you may specify the environment
	//by passing in ENV_LIVE (default), ENV_SANDBOX, or ENV_NONE (offline demo mode).
    [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
    
	
    //	[PayPal initializeWithAppID:@"your live app id" forEnvironment:ENV_LIVE];
	//[PayPal initializeWithAppID:@"anything" forEnvironment:ENV_NONE];
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
