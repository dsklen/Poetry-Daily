//
//  PDFavoritesViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 5/31/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDFavoritesViewController.h"
#import "PDFavoritesCoverFlowViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface PDFavoritesViewController ()

- (IBAction)sortFavorites:(id)sender;
- (void)orientationChanged:(NSNotification *)notification;

@end

@implementation PDFavoritesViewController

@synthesize isShowingLandscapeView = _isShowingLandscapeView;


#pragma mark - API

- (IBAction)sortFavorites:(id)sender;
{
    
}


#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Favorites", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [UIImage imageNamed:@"first"],
											 [UIImage imageNamed:@"second"],
											 nil]];
    
    segmentedControl.selectedSegmentIndex = 1;
    
    [segmentedControl addTarget:self action:@selector(sortFavorites:) forControlEvents:UIControlEventValueChanged];
    
    
    segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = NO;
	
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    
    
    self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !self.isShowingLandscapeView)
    {
        PDFavoritesCoverFlowViewController *favoriteFlow = [[PDFavoritesCoverFlowViewController alloc] initWithNibName:@"PDFavoritesCoverFlowViewController" bundle:nil];
        favoriteFlow.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

        [self presentModalViewController:favoriteFlow animated:YES];
        self.isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && self.isShowingLandscapeView)
    {
        [UIView animateWithDuration:0.5f animations:^{
                    
        } completion:^(BOOL finished) {
            [self dismissModalViewControllerAnimated:YES];
            self.isShowingLandscapeView = NO;
        }];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return YES;
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
}


#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 60.0f, 80.0f)];
        thumbnailImageView.tag = 99;
        thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        thumbnailImageView.clipsToBounds = YES;
        thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
        thumbnailImageView.clipsToBounds = NO;
        thumbnailImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        thumbnailImageView.layer.shadowOffset = CGSizeMake( 2.0f, 2.0f );
        thumbnailImageView.layer.shadowRadius = 4.0f;
        thumbnailImageView.layer.shadowOpacity = 0.5f;       
        thumbnailImageView.layer.shouldRasterize = YES;
        thumbnailImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [cell.contentView addSubview:thumbnailImageView];
        
        UILabel *poemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 10.0f, 230.0f, 20.0f)];
        poemTitleLabel.text = @"Poem Title Goes Here";
        poemTitleLabel.tag = 100;
        poemTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        poemTitleLabel.textAlignment = UITextAlignmentLeft;
        poemTitleLabel.textColor = [UIColor darkGrayColor];
        poemTitleLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:poemTitleLabel];
        
        UILabel *authorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 30.0f, 230.0f, 20.0f)];
        authorNameLabel.text = @"By David Sklenar";
        authorNameLabel.tag = 101;
        authorNameLabel.textAlignment = UITextAlignmentLeft;
        authorNameLabel.font = [UIFont systemFontOfSize:12.0f];
        authorNameLabel.textColor = [UIColor darkGrayColor];
        authorNameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:authorNameLabel];
        
//        UILabel *airingDateAndChannelLabel = [[UILabel alloc] initWithFrame:CGRectMake(127.0f, 50.0f, 300.0f, 20.0f)];
//        airingDateAndChannelLabel.tag = 102;
//        airingDateAndChannelLabel.font = [UIFont systemFontOfSize:12.0f];
//        airingDateAndChannelLabel.textAlignment = UITextAlignmentLeft;
//        airingDateAndChannelLabel.textColor = [UIColor lightGrayColor];
//        airingDateAndChannelLabel.backgroundColor = [UIColor clearColor];
//        [cell.contentView addSubview:airingDateAndChannelLabel];        
            
        UIButton *lockUnlockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        lockUnlockButton.tag = 104;
        lockUnlockButton.frame = CGRectMake(490, 0.0f, 40.0f, 100.0f);
        [lockUnlockButton setImage:[UIImage imageNamed:@"dvr_unlocked_icon"] forState:UIControlStateNormal];
        [lockUnlockButton addTarget:self action:@selector(batchLockOrUnlockAiring:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:lockUnlockButton];
        
//        UIButton *deleteRecordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        deleteRecordingButton.tag = 105;
//        deleteRecordingButton.frame = CGRectMake(530.0f, 0.0f, 40.0f, 100.0f);
//        [deleteRecordingButton setImage:[UIImage imageNamed:@"dvr_trash_icon"] forState:UIControlStateNormal];
//        [deleteRecordingButton addTarget:self action:@selector(showAlertViewToBatchDeleteRecordings:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.contentView addSubview:deleteRecordingButton];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}
@end
