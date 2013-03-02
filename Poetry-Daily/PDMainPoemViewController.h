//
//  PDMainPoemViewController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 5/24/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@class PDPoem;

@interface PDMainPoemViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *poemTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *poemAuthorLabel;

@property (strong, nonatomic) PDPoem *currentPoem;

- (IBAction)returnToHomeView:(id)sender;

@end
