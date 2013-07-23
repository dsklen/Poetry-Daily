//
//  PDAppDelegate.h
//  Poetry-Daily
//
//  Created by David Sklenar on 4/10/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDWindow;
@class ISRevealController;

@interface PDAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) ISRevealController *revealViewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UINavigationController *viewController;


- (void)showPoemForDay:(NSNotification *)aNotification;
- (void)showTodaysPoem:(NSNotification *)aNotification;


@end
