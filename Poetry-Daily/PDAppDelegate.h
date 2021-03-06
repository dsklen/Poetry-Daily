//
//  PDAppDelegate.h
//  Poetry-Daily
//
//  Created by David Sklenar on 4/10/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDWindow;

@interface PDAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;


- (void)showPoemForDay:(NSNotification *)aNotification;
- (void)showTodaysPoem:(NSNotification *)aNotification;


@end
