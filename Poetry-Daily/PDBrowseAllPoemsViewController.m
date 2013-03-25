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
#import "PDMediaServer.h"
#import "SVProgressHUD.h"

#import "OHAttributedLabel.h"
#import "OHASBasicHTMLParser.h"
#import "NSTextCheckingResult+ExtendedURL.h"
#import <CoreText/CoreText.h>
#import "NSAttributedString+Attributes.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface PDBrowseAllPoemsViewController ()
- (void)orientationChanged:(NSNotification *)notification;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (IBAction)sortPoems:(id)sender;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (readwrite, nonatomic) BOOL isIOS6;

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
        [self.poemsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    else 
    {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
        [self.displayPoemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

        [self.poemsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.poemsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
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
        
        [senderButton setTitle:@"★"];
    }
    
    if ( [self.poemsArray count] > 0 )
        [self.poemsTableView reloadData];
}

- (IBAction)favoriteOrUnfavoritePoem:(id)sender;
{      
    UIButton *senderButton = (UIButton *)sender;
    
    UITableViewCell *cell = (UITableViewCell *) [[senderButton superview] superview];
    NSIndexPath *indexPath = [self.poemsTableView indexPathForCell:cell]; 
    
    PDPoem *poem = [self.displayPoemsArray objectAtIndex:indexPath.row];

    if ([senderButton.titleLabel.text isEqualToString:@"★"])
    {
        poem.isFavorite = [NSNumber numberWithBool:NO];
        [senderButton setTitle:@"☆" forState:UIControlStateNormal];
        
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:NSLocalizedString( @"Unfavorited", @"" ) ];

    }
    else
    {
        poem.isFavorite = [NSNumber numberWithBool:YES];
        [senderButton setTitle:@"★" forState:UIControlStateNormal];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString( @"Favorited", @"" )];

    }
    
    
//    if ( poem.isFavorite.boolValue )
//        [(UIButton *)[cell.contentView viewWithTag:104] setTitle:@"☆" forState:UIControlStateNormal];
//    else
//        [(UIButton *)[cell.contentView viewWithTag:104] setTitle:@"★" forState:UIControlStateNormal];

    
    
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
                                                                  [UIColor whiteColor], UITextAttributeTextColor,
                                                                  nil];
        
        [self.tabBarItem setTitleTextAttributes:titleTextAttributesDictionary forState:UIControlStateNormal];
        [self.tabBarItem setTitleTextAttributes:titleTextHighlightedAttributesDictionary forState:UIControlStateSelected];
        
        
        
        _isIOS6 = NO;// ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) ;
        
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.dateFormatter = dateFormatter;
    
    
    // Add sorting segmented control.
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [NSString stringWithFormat:@""],
											 [NSString stringWithFormat:@""],
											 nil]];
    
    [segmentedControl setImage:[UIImage imageNamed:@"calendar_alt_fill_16x16"] forSegmentAtIndex:0];
    [segmentedControl setImage:[UIImage imageNamed:@"list_16x14"] forSegmentAtIndex:1];
    
    segmentedControl.selectedSegmentIndex = 0;
    
    [segmentedControl addTarget:self action:@selector(sortPoems:) forControlEvents:UIControlEventValueChanged];
    
    segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = NO;
	
    segmentedControl.tintColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    
    // Add favorites toggle
    
    UIBarButtonItem *favoritesBarItem = [[UIBarButtonItem alloc] initWithTitle:@"★" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleFavorites:)];
    
    [favoritesBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0], UITextAttributeTextColor,
                                              [UIColor whiteColor], UITextAttributeTextShadowColor,
                                              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                              [UIFont boldSystemFontOfSize:16.0f], UITextAttributeFont,
                                              nil] forState:UIControlStateNormal];

    
    self.navigationItem.leftBarButtonItem = favoritesBarItem;
    
    

    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];
    
    
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
    return;
        
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
    return 104.0f;
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
        
        
        
        if ( self.isIOS6 )
        {        
            OHAttributedLabel *poemTitleLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(80.0f, 10.0f, 230.0f, 20.0f)];
            poemTitleLabel.tag = 100;
            poemTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            poemTitleLabel.textAlignment = UITextAlignmentLeft;
            poemTitleLabel.textColor = [UIColor darkGrayColor];
            poemTitleLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:poemTitleLabel];
        }
        else
        {
            UILabel *poemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 10.0f, 230.0f, 20.0f)];
            poemTitleLabel.tag = 100;
            poemTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            poemTitleLabel.textAlignment = UITextAlignmentLeft;
            poemTitleLabel.textColor = [UIColor darkGrayColor];
            poemTitleLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:poemTitleLabel];
        }
        
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
        [favoriteUnfavoriteButton setTitleColor: [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0] forState:UIControlStateNormal];
//        [favoriteUnfavoriteButton setImage:[UIImage imageNamed:@"unfilledFavoriteStar"] forState:UIControlStateNormal];
        
//        favoriteUnfavoriteButton.layer.shadowColor = [UIColor blackColor].CGColor;
//        favoriteUnfavoriteButton.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
//        favoriteUnfavoriteButton.layer.shadowRadius = 2.0f;
//        favoriteUnfavoriteButton.layer.shadowOpacity = 0.5f;

        [favoriteUnfavoriteButton addTarget:self action:@selector(favoriteOrUnfavoritePoem:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:favoriteUnfavoriteButton];
    }
    
    PDPoem *poem;
    
    if ( tableView == self.searchDisplayController.searchResultsTableView )
        poem = [self.filteredPoemsArray objectAtIndex:indexPath.row];        
    else
        poem = [self.displayPoemsArray objectAtIndex:indexPath.row];
    
    
    
    if ( self.isIOS6 )
    {
        OHAttributedLabel *label = (OHAttributedLabel *)[cell.contentView viewWithTag:100];
        NSMutableAttributedString *poemTitle = [OHASBasicHTMLParser attributedStringByProcessingMarkupInAttributedString:[NSAttributedString attributedStringWithString:poem.title]];

        
        if ( poem.title.length > 0)
        {
            [poemTitle setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0f], NSForegroundColorAttributeName : [UIColor darkGrayColor]} range:NSMakeRange(0, poem.title.length)];
        }
        
        label.attributedText = poemTitle;

    }
    else
    {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
 
        label.font = [UIFont boldSystemFontOfSize:14.0f];
        label.textColor = [UIColor darkGrayColor];
        
        label.text = poem.title;
    }

    
    [(UILabel *)[cell.contentView viewWithTag:101] setText:poem.author];
    
    if ( poem.authorImageData.length > 0 && poem.hasAttemptedDownload )
    {
        [(UIImageView *)[cell.contentView viewWithTag:99] setImage:poem.authorImage];
    }
    else
    {
        [(UIImageView *)[cell.contentView viewWithTag:99] setImage:[UIImage imageNamed:@"default-avatar"]];
        
        if ( poem.authorImageURLString.length > 0)
        {
            PDMediaServer *server = [[PDMediaServer alloc] init];
            
            [server fetchPoetImagesWithStrings:@[poem.authorImageURLString] isJournalImage:poem.isJournalImage block:^(NSArray *items, NSError *error) {
                
                if ( items && !error )
                {
                    NSData *newImageData = items[0];
                    
                    poem.authorImageData = newImageData;

                    [(UIImageView *)[cell.contentView viewWithTag:99] setImage:poem.authorImage];
                    
                    poem.hasAttemptedDownload = YES;
                }
                else
                {
                    poem.hasAttemptedDownload = NO;
                }
                
            }];
        }
    }
    

    [(UILabel *)[cell.contentView viewWithTag:102] setText:[self.dateFormatter stringFromDate:poem.publishedDate]];

//    if ( poem.isFavorite.boolValue )
//        [(UIButton *)[cell.contentView viewWithTag:104] setImage:[UIImage imageNamed:@"favoriteStar"] forState:UIControlStateNormal];
//    else
//        [(UIButton *)[cell.contentView viewWithTag:104]  setImage:[UIImage imageNamed:@"unfilledFavoriteStar"] forState:UIControlStateNormal];
    
    if ( poem.isFavorite.boolValue )
        [(UIButton *)[cell.contentView viewWithTag:104] setTitle:@"★" forState:UIControlStateNormal];
    else
        [(UIButton *)[cell.contentView viewWithTag:104] setTitle:@"☆" forState:UIControlStateNormal];
    
    
    if (indexPath.row % 2 == 0 )
    {
//        [(UILabel *)[cell.contentView viewWithTag:101] setBackgroundColor:[UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f]];
//        [(UILabel *)[cell.contentView viewWithTag:102] setBackgroundColor:[UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f]];
	}
    else
	{
//        [(UILabel *)[cell.contentView viewWithTag:101] setBackgroundColor:[UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f]];
//        [(UILabel *)[cell.contentView viewWithTag:102] setBackgroundColor:[UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f]];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0 )
    {
		cell.contentView.backgroundColor = [UIColor clearColor];// colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.8f];
        cell.accessoryView.backgroundColor = [UIColor clearColor];//  colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.8f];

        cell.backgroundColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];
	}
    else 
	{
        cell.contentView.backgroundColor = [UIColor clearColor];// colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f];
        cell.accessoryView.backgroundColor = [UIColor clearColor];// colorWithRed:.8819f green:.84212f blue:.7480f alpha:0.6f];

        
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
