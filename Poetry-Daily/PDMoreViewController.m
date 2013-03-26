//
//  PDMoreViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/8/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDMoreViewController.h"
#import "PDDonationsViewController.h"
#import "PDAboutPDViewController.h"
#import "PDSponsorsView.h"
#import "SVModalWebViewController.h"
#import <CoreData/CoreData.h>
#import "PDConstants.h"
#import "PDCachedDataController.h"
#import "PDSponsor.h"
#import "SVProgressHUD.h"

@interface PDMoreViewController ()

- (IBAction)showAboutPage:(id)sender;

@end

@implementation PDMoreViewController


- (IBAction)showAboutPage:(id)sender;
{
    PDAboutPDViewController *about = [[PDAboutPDViewController alloc] initWithNibName:@"PDAboutPDViewController" bundle:nil];
    [self.navigationController pushViewController:about animated:YES];

}

- (IBAction)showSponsorLink:(id)sender;
{
    PDSponsor *sponsor = [self.sponsors objectAtIndex:self.carousel.currentItemIndex];
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:sponsor.siteURL]];
    
    webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    webViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    webViewController.navigationBar.tintColor =  [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];

    [self presentModalViewController:webViewController animated:YES];
    
    webViewController.navigationBar.tintColor =  [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    webViewController.toolbar.tintColor = [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0];

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        self.title = NSLocalizedString(@"Sponsors", @"");
        
        self.tabBarItem.image = [UIImage imageNamed:@"nav_icon_ios_more"];
        
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
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if ( self )
    {
        self.title = NSLocalizedString(@"Sponsors", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"nav_icon_ios_more"];
        
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
    }
    
    
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(showAboutPage:)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0], UITextAttributeTextColor,
                                              [UIColor whiteColor], UITextAttributeTextShadowColor,
                                              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                              [UIFont boldSystemFontOfSize:14.0f], UITextAttributeFont,
                                              nil] forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:0.6f];

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.carousel.type = iCarouselTypeRotary;
    else
        self.carousel.type = iCarouselTypeLinear;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.carousel.decelerationRate = 0.85;
//        self.carousel.contentOffset = CGSizeMake( -220.0f, 0.0f );
    
    }
    
    self.carousel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-Linen"]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sponsor"];
    request.fetchLimit = 10;
    
    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
    [serverInfo setObject:[NSNumber numberWithInteger:PDServerCommandSponsors] forKey:PDServerCommandKey];
    
    NSArray *items = [[PDCachedDataController sharedDataController] fetchObjects:request serverInfo:serverInfo cacheUpdateBlock:^(NSArray *newResults, NSError *error) {
        
        if ( newResults && !error )
        {
            self.sponsors = [newResults mutableCopy];
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
            [self.sponsors sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            
            [self.carousel reloadData];
            
            [SVProgressHUD dismiss];
        }
        else
        {
            [SVProgressHUD dismissWithError:@"Failed To Load"];
        }
        
    }];
    
    self.sponsors = [items mutableCopy];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [self.sponsors sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    
    if ( [self.sponsors count] == 0 )
        [SVProgressHUD showWithStatus:NSLocalizedString( @"Loading Sponsors...", @"" )];
    
    
    [self.carousel reloadData];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_new"]];
    ;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0)
        return 2;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 )
        if ( indexPath.row == 0 )
            return self.sponsorsTableViewCell;
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ( indexPath.section == 0)
    {
        if ( indexPath.row == 0)
            cell.textLabel.text = @"";
        if ( indexPath.row == 1)
            cell.textLabel.text = @"Donate today!";
    }
    
    if ( indexPath.section == 1)
    {
        if ( indexPath.row == 0)
            cell.textLabel.text = @"About PD";
    }
    if ( indexPath.section == 2)
    {
        if ( indexPath.row == 0)
            cell.textLabel.text = @"About PD";
        if ( indexPath.row == 1)
            cell.textLabel.text = @"About the app";
    }
    
    cell.textLabel.backgroundColor= [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.accessoryView.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ( indexPath.section == 0 && indexPath.row == 0 ) return self.sponsorsTableViewCell.frame.size.height;
    
    return 44.0f;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_new"]];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if (indexPath.section == 0) {
        if (indexPath.row==1) {
            PDDonationsViewController *donationsViewController = [[PDDonationsViewController alloc] initWithNibName:@"PDDonationsViewController" bundle:nil];
            [self.navigationController pushViewController:donationsViewController animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        if ( indexPath.row==0) {
            PDAboutPDViewController *about = [[PDAboutPDViewController alloc] initWithNibName:@"PDAboutPDViewController" bundle:nil];
            [self.navigationController pushViewController:about animated:YES];
        }
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0.0f;
    return 44.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    return  nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    return nil;

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 44.0f )];
    containerView.backgroundColor = [UIColor colorWithRed:90.0f/255.0 green:33.0f/255.0 blue:40.0f/255.0 alpha:1.0];
//    containerView.layer.shadowOpacity = 0.5f;
//    containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    containerView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
//    containerView.layer.shadowRadius = 2.0f;
    
    UILabel *title = [[UILabel alloc] initWithFrame:containerView.frame];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
    title.font = [UIFont boldSystemFontOfSize:16.0f];
    
    if ( section == 0)
        title.text =  @"   Sponsors";
    
    if ( section == 1)
        title.text = @"   About";
    
    [containerView addSubview:title];
    
    return containerView;
;
}

#pragma mark - iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.sponsors count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *name = nil;
    UIWebView *description = nil;
    UIImageView *logo = nil;
    UIButton *linkButton = nil;

    //create new view if no view is available for recycling
    if ( view == nil )
    {
        view = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 150.0f, 257.0f )];
        view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        view.layer.borderWidth = 4.0f;
        view.backgroundColor = [UIColor lightGrayColor];
        view.tag = 100;
        view.contentMode = UIViewContentModeCenter;

        logo = [[UIImageView alloc] initWithFrame:CGRectMake(28.0f, 48.0f, 92.0f, 92.0f)];
        [view addSubview:logo];
        logo.tag = 2;
        
        name = [[UILabel alloc] initWithFrame:CGRectMake(4.0f, 0.0f, 142.0f, 54.0f)];
        name.backgroundColor = [UIColor clearColor];
        name.textColor = [UIColor darkGrayColor];
        name.textAlignment = UITextAlignmentCenter;
        name.font = [UIFont boldSystemFontOfSize:12.0f];
        name.numberOfLines = 0;
        name.tag = 1;
        [view addSubview:name];
        
        description = [[UIWebView alloc] initWithFrame:CGRectMake(5.0f, 157.0f, 140.0f, 91.0f)];
        description.backgroundColor = [UIColor clearColor];
        description.opaque = NO;
        description.tag = 3;
        description.scrollView.scrollEnabled = NO;
        [view addSubview:description];
        
        linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [linkButton setTitle:@"More ⇗" forState:UIControlStateNormal];
        [linkButton setTitleColor:[UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [linkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        linkButton.frame = CGRectMake( 39.0f, 132.0f, 72.0f, 44.0f);
//        [linkButton setImage:[UIImage imageNamed:@"fullscreen_alt_16x16"] forState:UIControlStateNormal];
        [linkButton addTarget:self action:@selector(showSponsorLink:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:linkButton];
    }
    else
    {
        //get a reference to the label in the recycled view
        name = (UILabel *)[view viewWithTag:1];
        description = (UIWebView *)[view viewWithTag:3];
        logo = (UIImageView *)[view viewWithTag:2];
    }
    
    PDSponsor *sponsor = [self.sponsors objectAtIndex:index];
    
    if (index % 2 == 0 )
    {
        view.backgroundColor = [UIColor colorWithRed:1.0f green:.9921f blue:.9252f alpha:1.0f];
	}
    else
	{
        view.backgroundColor = [UIColor colorWithRed:.8819f green:.84212f blue:.7480f alpha:1.0f];
    }
    
    name.text = sponsor.name;
    [logo setImage:sponsor.image];
    
    NSMutableString *HTMLString = [[NSMutableString alloc] init];
    [HTMLString appendString:@""];
    
    NSString *loadedHTML = [description stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    
    if ( [loadedHTML rangeOfString:sponsor.text].location == NSNotFound  )
    {
        [description loadHTMLString:sponsor.text baseURL:nil];
    }

    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            return value * 1.05f;
        else
            return value * 1.25f;
    }
    
    return value;
}

//- (void)carouselDidScroll:(iCarousel *)carousel;
//{
//    if ( self.tableView.contentOffset.y > 10.0f )
//    {
//        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//    }
//    
//}

@end
