//
//  PDBrowseAllGridViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 3/26/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDBrowseAllGridViewController.h"
#import "PDPoem.h"
#import <QuartzCore/QuartzCore.h>
#import "PDCachedDataController.h"
#import "PDMainPoemViewController.h"
#import "PDMediaServer.h"
#import "SVProgressHUD.h"
#import "PDBrowseGridPoemCell.h"
#import "PDMainPoemViewController.h"
#import "PDConstants.h"

@interface PDBrowseAllGridViewController ()

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (IBAction)sortPoems:(id)sender;
- (void)hide;


@end



@implementation PDBrowseAllGridViewController


- (void)viewDidLoad;
{
//    self.poemsArray = [NSMutableArray array];
//    self.filteredPoemsArray = [NSMutableArray array];
    self.poemsMode = PDShowPoemsModeAll;

//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Poem"];
//    
//    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
//    [serverInfo setObject:[NSNumber numberWithInteger:PDServerCommandAllPoems] forKey:PDServerCommandKey];
//    
//    NSArray *items = [[PDCachedDataController sharedDataController] fetchObjects:request serverInfo:serverInfo cacheUpdateBlock:^(NSArray *newResults, NSError *error) {
//        
//        if ( newResults && !error )
//        {
//            self.poemsArray = [newResults mutableCopy];
//            
//            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
//            [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
//            
//            self.displayPoemsArray = self.poemsArray;
//            
//            [self.collectionView reloadData];
//            
//            [SVProgressHUD dismiss];
//        }
//        else
//            [SVProgressHUD dismissWithError:@"Failed To Load"];
//        
//    }];
//    
//    if ( [items count] > 0 )
//    {
//        self.poemsArray = [items mutableCopy];
//        
//        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
//        [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
//        
//        self.displayPoemsArray = self.poemsArray;
//        
//        [self.collectionView reloadData];
//        
//        [SVProgressHUD dismiss];
//    }
    

    
    
    UIBarButtonItem *favoritesBarItem = [[UIBarButtonItem alloc] initWithTitle:@"★" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleFavorites:)];
    
    [favoritesBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0], UITextAttributeTextColor,
                                              [UIColor whiteColor], UITextAttributeTextShadowColor,
                                              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                              [UIFont boldSystemFontOfSize:16.0f], UITextAttributeFont,
                                              nil] forState:UIControlStateNormal];
    
    
    self.navigationItem.leftBarButtonItem = favoritesBarItem;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list_16x14"] landscapeImagePhone:[UIImage imageNamed:@"list_16x14"] style:UIBarButtonItemStyleBordered target:self action:@selector(hide)];
    
    
    [self.collectionView registerClass:[PDBrowseGridPoemCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPoemForDay:) name:@"PDOpenPoemFromGrid" object:nil];

    if ( [self.displayPoemsArray count] < [self.poemsArray count] )
    {
        self.poemsMode = PDShowPoemsModeAll;
        [self toggleFavorites:nil];
    }
}

- (void)hide;
{
    if ( [self.navigationController respondsToSelector:@selector(popToRootViewControllerAnimated:)] )
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
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
    
    if ( [self.displayPoemsArray count] > 0 )
        [self.collectionView reloadData];
}

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


- (IBAction)sortPoems:(id)sender;
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    
    if (seg.selectedSegmentIndex == 1)
    {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        [self.displayPoemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    else
    {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
        [self.displayPoemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        [self.poemsArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
}


#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.displayPoemsArray count];
}

#pragma mark - PSTCollectionViewDelegate

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    PDBrowseGridPoemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    
    PDPoem *poem;
    poem = [self.displayPoemsArray objectAtIndex:indexPath.row];
    
    if ( poem.authorImageData.length > 0 && poem.hasAttemptedDownload )
    {
        cell.imageView.image = poem.authorImage;
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"default-avatar"];

        if ( poem.authorImageURLString.length > 0)
        {
            PDMediaServer *server = [[PDMediaServer alloc] init];
            
            [server fetchPoetImagesWithStrings:@[poem.authorImageURLString] isJournalImage:poem.isJournalImage block:^(NSArray *items, NSError *error) {
                
                if ( items && !error )
                {
                    NSData *newImageData = [items lastObject];
                    
                    if ( newImageData )
                        if ( [newImageData isKindOfClass:[NSData class]])
                        {
                            poem.authorImageData = newImageData;
                            cell.imageView.image = poem.authorImage;
                            poem.hasAttemptedDownload = YES;
                        }
                }
                else
                {
                    poem.hasAttemptedDownload = NO;
                }
                
            }];
        }
    }

    
    cell.subtitleLabel.text = poem.author;
    
    NSMutableString *titleAttributedString = [NSMutableString stringWithString:poem.title];
    titleAttributedString = [[titleAttributedString stringByReplacingOccurrencesOfString:@"<i>" withString:@""] mutableCopy];
    titleAttributedString = [[titleAttributedString stringByReplacingOccurrencesOfString:@"</i>" withString:@""] mutableCopy];
    
    cell.titleLabel.text = titleAttributedString;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {    
        NSString *string = poem.title;
        CGSize maximumLabelSize = CGSizeMake( 80.0f, 9999.0f );
        CGSize expectedLabelSize = [string sizeWithFont:[UIFont boldSystemFontOfSize:12.0f] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        
        CGRect titleFrame = cell.titleLabel.frame;
        titleFrame.size = expectedLabelSize;
        titleFrame.origin.x = 5.0f;
        titleFrame.size.width = 80.0f;

        cell.titleLabel.frame = titleFrame;
        
        cell.titleLabel.textAlignment = UITextAlignmentCenter;
        
        CGRect subtitleFrame = cell.subtitleLabel.frame;
        subtitleFrame.origin.y = expectedLabelSize.height + 125.0f;
        cell.subtitleLabel.frame = subtitleFrame;
    }
    else
    {
        NSString *string = poem.title;
        CGSize maximumLabelSize = CGSizeMake( 160.0f, 9999.0f );
        CGSize expectedLabelSize = [string sizeWithFont:[UIFont boldSystemFontOfSize:12.0f] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        
        CGRect titleFrame = cell.titleLabel.frame;
        titleFrame.size = expectedLabelSize;
        titleFrame.origin.x = 10.0f;
        titleFrame.size.width = 160.0f;
        
        cell.titleLabel.frame = titleFrame;
        
        cell.titleLabel.textAlignment = UITextAlignmentCenter;
        
        CGRect subtitleFrame = cell.subtitleLabel.frame;
        subtitleFrame.origin.y = expectedLabelSize.height + 225.0f;
        cell.subtitleLabel.frame = subtitleFrame;
    }
    cell.poemID = poem.poemID;

    return cell;
}

#pragma mark - PSTCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        PDPoem *poem;
        poem = [self.displayPoemsArray objectAtIndex:indexPath.row];
        
        NSMutableString *titleAttributedString = [NSMutableString stringWithString:poem.title];
        titleAttributedString = [[titleAttributedString stringByReplacingOccurrencesOfString:@"<i>" withString:@""] mutableCopy];
        titleAttributedString = [[titleAttributedString stringByReplacingOccurrencesOfString:@"</i>" withString:@""] mutableCopy];
                
        NSString *string = poem.title;
        CGSize maximumLabelSize = CGSizeMake( 80.0f, 9999.0f );
        CGSize expectedLabelSize = [string sizeWithFont:[UIFont boldSystemFontOfSize:12.0f] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        
        return CGSizeMake( 90.0f, expectedLabelSize.height + 140.0f);
    }
    else
    {
        PDPoem *poem;
        poem = [self.displayPoemsArray objectAtIndex:indexPath.row];
        
        NSMutableString *titleAttributedString = [NSMutableString stringWithString:poem.title];
        titleAttributedString = [[titleAttributedString stringByReplacingOccurrencesOfString:@"<i>" withString:@""] mutableCopy];
        titleAttributedString = [[titleAttributedString stringByReplacingOccurrencesOfString:@"</i>" withString:@""] mutableCopy];
        
        NSString *string = poem.title;
        CGSize maximumLabelSize = CGSizeMake( 80.0f, 9999.0f );
        CGSize expectedLabelSize = [string sizeWithFont:[UIFont boldSystemFontOfSize:12.0f] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        
        return CGSizeMake( 180.0f, expectedLabelSize.height + 240.0f);
    }
    
    return CGSizeZero;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return 10.0f;
    else
        return 2.0f;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    return 10.0f;
}

- (UIEdgeInsets)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
{
    return UIEdgeInsetsMake( 10.0f, 15.0f, 10.0f, 15.0f );
}


- (void)showPoemForDay:(NSNotification *)aNotification;
{    
    NSString *poemID = [aNotification object];
    NSArray *poemSearch = [self.displayPoemsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.poemID == %@", poemID]];

    PDPoem *poem = [poemSearch lastObject];
    
    if ( poem)
    {
        PDMainPoemViewController *mainViewController = [[PDMainPoemViewController alloc] initWithNibName:@"PDMainPoemViewController" bundle:nil];
        [self.navigationController pushViewController:mainViewController animated:YES];
        [mainViewController setCurrentPoem:poem];

    }
}


@end
