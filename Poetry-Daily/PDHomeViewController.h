//
//  PDHomeViewController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 5/24/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDPoem;
@class PullRefreshTableViewController;

@interface PDHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) PDPoem *currentPoem;
@property (strong, nonatomic) IBOutlet UILabel *poemPublishedDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *poemTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *poemAuthorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *poemAuthorImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *poemAuthorImageActivityView;
@property (strong, nonatomic) IBOutlet UIButton *readPoemButton;
@property (strong, nonatomic) IBOutlet UIButton *showPreviousDayButton;
@property (strong, nonatomic) IBOutlet UIButton *showNextDayButton;
@property (strong, nonatomic) IBOutlet UILabel *todaysPoemLabel;
@property (strong, nonatomic) IBOutlet UIWebView *poemInformationWebView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *mainPoemTableViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *readPoemButtonTableViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *poetInformationTableViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *publicationInformationTableViewCell;
@property (strong, nonatomic) IBOutlet UIWebView *poetInfoWebView;
@property (strong, nonatomic) IBOutlet UIWebView *publicationInfoWebView;

@property (nonatomic, strong) UIBarButtonItem *favoriteBarButtonItem;

@property (strong, nonatomic) IBOutlet UIWebView *iPadfeatureInformationWebView;
@property (strong, nonatomic) IBOutlet UIButton *iPadVisitPublicationPageButton;

@property (strong, nonatomic) IBOutlet PullRefreshTableViewController  *pullToRefreshController;

- (IBAction)showMainPoemView:(id)sender;
- (IBAction)fetchRandomPoem:(id)sender;
- (IBAction)showPreviousDay:(id)sender;
- (IBAction)showNextDay:(id)sender;
- (IBAction)showPublicationSite:(id)sender;
- (IBAction)showFeatureInformation:(id)sender;

- (void)showPoemForDay:(NSDate *)date;


@end
