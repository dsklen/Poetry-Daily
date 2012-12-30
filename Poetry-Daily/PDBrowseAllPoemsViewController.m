//
//  PDBrowseAllPoemsViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/4/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDBrowseAllPoemsViewController.h"
#import "PDFavoritesCoverFlowViewController.h"
#import "PDPoem.h"
#import <QuartzCore/QuartzCore.h>
#import "PDCachedDataController.h"
#import "PDMainPoemViewController.h"

@interface PDBrowseAllPoemsViewController ()
- (void)orientationChanged:(NSNotification *)notification;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (IBAction)sortPoems:(id)sender;

@end

@implementation PDBrowseAllPoemsViewController

#pragma mark - Properties

@synthesize isShowingLandscapeView = _isShowingLandscapeView;
@synthesize poemsArray = _poemsArray;
@synthesize filteredPoemsArray = _filteredPoemsArray;
@synthesize poemsTableView = _poemsTableView;
@synthesize searchController = _searchController;


#pragma mark - API

- (IBAction)sortPoems:(id)sender;
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    
    if (seg.selectedSegmentIndex == 1)
    {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        [self.displayPoemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

        [self.poemsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]; 
        [self.poemsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
    }
    else 
    {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
        [self.displayPoemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

        [self.poemsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.poemsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
    }
}

- (IBAction)toggleFavorites:(id)sender;
{
    UIBarButtonItem *senderButton = (UIBarButtonItem *)sender;
    
    if ( self.poemsMode == PDShowPoemsModeAll )
    {
        self.poemsMode = PDShowPoemsModeFavoritesOnly;
        
        self.displayPoemsArray = self.poemsArray;
        self.displayPoemsArray = [[self.displayPoemsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.isFavorite == TRUE"]] mutableCopy];
        
        [senderButton setTitle:@"All"];
    }
    else
    {
        self.poemsMode = PDShowPoemsModeAll;

        self.displayPoemsArray = self.poemsArray;
        
        [senderButton setTitle:@"Favorites"];
    }
    
    if ( [self.poemsArray count] > 0 )
        [self.poemsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)favoriteOrUnfavoritePoem:(id)sender;
{      
    UIButton *senderButton = (UIButton *)sender;
    
    UITableViewCell *cell = (UITableViewCell *) [[senderButton superview] superview];
    NSIndexPath *indexPath = [self.poemsTableView indexPathForCell:cell]; 
    
    PDPoem *poem = [self.displayPoemsArray objectAtIndex:indexPath.row];

    if (senderButton.imageView.image == [UIImage imageNamed:@"favoriteStar"])
    {
        poem.isFavorite = [NSNumber numberWithBool:NO];
        [senderButton setImage:[UIImage imageNamed:@"unfilledFavoriteStar"] forState:UIControlStateNormal];
    }
    else
    {
        poem.isFavorite = [NSNumber numberWithBool:YES];
        [senderButton setImage:[UIImage imageNamed:@"favoriteStar"] forState:UIControlStateNormal];
    }
}


#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) 
    {
        self.title = NSLocalizedString(@"Archive", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"33-cabinet"];
        
        NSDictionary *titleTextAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont boldSystemFontOfSize:10.0f], UITextAttributeFont,
                                                       [UIColor darkGrayColor], UITextAttributeTextColor,
                                                       nil];
        
        NSDictionary *titleTextHighlightedAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont boldSystemFontOfSize:10.0f], UITextAttributeFont,
                                                                  [UIColor blackColor], UITextAttributeTextColor,
                                                                  nil];
        
        [self.tabBarItem setTitleTextAttributes:titleTextAttributesDictionary forState:UIControlStateNormal];
        [self.tabBarItem setTitleTextAttributes:titleTextHighlightedAttributesDictionary forState:UIControlStateSelected];
        
        _poemsArray = [NSMutableArray array];
        _filteredPoemsArray = [NSMutableArray array];
        _poemsMode = PDShowPoemsModeAll;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    
    // Load all poems and update from server.
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Poem"];
    
    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [serverInfo setObject:[NSNumber numberWithInteger:PDServerCommandAllPoems] forKey:PDServerCommandKey];
    
    NSArray *items = [[PDCachedDataController sharedDataController] fetchObjects:request serverInfo:serverInfo cacheUpdateBlock:^(NSArray *newResults) {
        
        self.poemsArray = [newResults mutableCopy];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
        [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        
        self.displayPoemsArray = self.poemsArray;

        [self.poemsTableView reloadData];
    }];

    self.poemsArray = [items mutableCopy];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
    [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    
    self.displayPoemsArray = self.poemsArray;

    [self.poemsTableView reloadData];
    
    
    
    // Add sorting segmented control.
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [NSString stringWithFormat:@"123"],
											 [NSString stringWithFormat:@"AZ"],
											 nil]];
    
    segmentedControl.selectedSegmentIndex = 0;
    
    [segmentedControl addTarget:self action:@selector(sortPoems:) forControlEvents:UIControlEventValueChanged];
    
    segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = NO;
	
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    
    // Add favorites toggle
    
    UIBarButtonItem *favoritesBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Favorites" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleFavorites:)];
    self.navigationItem.leftBarButtonItem = favoritesBarItem;
    
    self.isShowingLandscapeView = NO;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (void)viewDidAppear:(BOOL)animated;
{
    // Load all poems (currently from cache - update command will be added once API is in place).
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Poem"];
    
    NSArray *items = [[PDCachedDataController sharedDataController] fetchObjects:request
                                                                      serverInfo:nil 
                                                                cacheUpdateBlock:nil];
    
    self.poemsArray = [items mutableCopy];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
    [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

    [self.poemsTableView reloadData];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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


#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PDPoem *selectedPoem;
    
    if ( tableView == self.searchDisplayController.searchResultsTableView )
        selectedPoem = [self.filteredPoemsArray objectAtIndex:indexPath.row];
    else
        selectedPoem = [self.displayPoemsArray objectAtIndex:indexPath.row];

    
    PDMainPoemViewController *mainViewController = [[PDMainPoemViewController alloc] initWithNibName:@"PDMainPoemViewController" bundle:nil];
    [self.navigationController pushViewController:mainViewController animated:YES];
    
    [mainViewController setCurrentPoem:selectedPoem];
}


#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if ( tableView == self.searchDisplayController.searchResultsTableView )
        return [self.filteredPoemsArray count];
    
    return [self.displayPoemsArray count];
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
        thumbnailImageView.image = [UIImage imageNamed:@"plumlystanley.jpeg"];;
        thumbnailImageView.clipsToBounds = YES;
        thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
        thumbnailImageView.clipsToBounds = NO;
        thumbnailImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        thumbnailImageView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
        thumbnailImageView.layer.shadowRadius = 2.0f;
        thumbnailImageView.layer.shadowOpacity = 0.5f;       
        thumbnailImageView.layer.shouldRasterize = YES;
        thumbnailImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [cell.contentView addSubview:thumbnailImageView];
        
        UILabel *poemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 10.0f, 230.0f, 20.0f)];
        poemTitleLabel.tag = 100;
        poemTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        poemTitleLabel.textAlignment = UITextAlignmentLeft;
        poemTitleLabel.textColor = [UIColor darkGrayColor];
        poemTitleLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:poemTitleLabel];
        
        UILabel *authorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 30.0f, 230.0f, 20.0f)];
        authorNameLabel.tag = 101;
        authorNameLabel.textAlignment = UITextAlignmentLeft;
        authorNameLabel.font = [UIFont systemFontOfSize:12.0f];
        authorNameLabel.textColor = [UIColor darkGrayColor];
        authorNameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:authorNameLabel];
        
        UILabel *publishedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 50.0f, 230.0f, 20.0f)];
        publishedDateLabel.tag = 102;
        publishedDateLabel.textAlignment = UITextAlignmentLeft;
        publishedDateLabel.font = [UIFont systemFontOfSize:12.0f];
        publishedDateLabel.textColor = [UIColor darkGrayColor];
        publishedDateLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:publishedDateLabel];      
        
        UIButton *favoriteUnfavoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        favoriteUnfavoriteButton.tag = 104;
        favoriteUnfavoriteButton.frame = CGRectMake(70.0f, 60.0f, 40.0f, 40.0f);
        favoriteUnfavoriteButton.imageView.contentMode = UIViewContentModeCenter;
        [favoriteUnfavoriteButton setImage:[UIImage imageNamed:@"unfilledFavoriteStar"] forState:UIControlStateNormal];
        [favoriteUnfavoriteButton addTarget:self action:@selector(favoriteOrUnfavoritePoem:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:favoriteUnfavoriteButton];
    }
    
    PDPoem *poem;
    
    if ( tableView == self.searchDisplayController.searchResultsTableView )
        poem = [self.filteredPoemsArray objectAtIndex:indexPath.row];        
    else
        poem = [self.displayPoemsArray objectAtIndex:indexPath.row];
    
    [(UILabel *)[cell.contentView viewWithTag:100] setText:poem.title];
    [(UILabel *)[cell.contentView viewWithTag:101] setText:poem.author];
    
    [(UIImageView *)[cell.contentView viewWithTag:99] setImage:poem.authorImage];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [(UILabel *)[cell.contentView viewWithTag:102] setText:[dateFormatter stringFromDate:poem.publishedDate]];

    if ( poem.isFavorite.boolValue )
        [(UIButton *)[cell.contentView viewWithTag:104] setImage:[UIImage imageNamed:@"favoriteStar"] forState:UIControlStateNormal];
    else
        [(UIButton *)[cell.contentView viewWithTag:104]  setImage:[UIImage imageNamed:@"unfilledFavoriteStar"] forState:UIControlStateNormal];
    
    
    if (indexPath.row % 2 == 0 )
    {
		cell.contentView.backgroundColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];
        cell.backgroundColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];
	}
    else 
	{
        cell.contentView.backgroundColor = [UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f];
        cell.backgroundColor = [UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f];
    }    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0 )
    {
		cell.contentView.backgroundColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.8f];
        cell.backgroundColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];
	}
    else 
	{
        cell.contentView.backgroundColor = [UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f];
        cell.backgroundColor = [UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.8f];
    }  
}


#pragma mark - UISearchDisplayController delegate methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope;
{
    NSPredicate *resultPredicate = nil;
    
    switch ( [self.searchDisplayController.searchBar selectedScopeButtonIndex] ) {
        case 0:
        {
            resultPredicate = [NSPredicate predicateWithFormat:@"SELF.title contains[cd] %@ OR SELF.author contains[cd] %@", searchText, searchText];
        }
            break;
        case 1:
        {
            resultPredicate = [NSPredicate predicateWithFormat:@"SELF.title contains[cd] %@", searchText];
        }
            break;
        case 2:
        {
            resultPredicate = [NSPredicate predicateWithFormat:@"SELF.author contains[cd] %@", searchText];
        }
            break;
            
        default:
            break;
    }

    self.filteredPoemsArray = [[self.poemsArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
}


@end
