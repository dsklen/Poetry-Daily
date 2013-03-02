//
//  PDMoreViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/8/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDMoreViewController.h"
#import "PDDonationsViewController.h"

@interface PDMoreViewController ()

@end

@implementation PDMoreViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        self.title = NSLocalizedString(@"More", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"more_info_tab_bg@2x"];
        
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.8819 green:.84212 blue:.7480 alpha:1.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0)
        return 2;
    
    if ( section == 1)
        return 1;
    
    if ( section == 2)
        return 2;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if ( indexPath.section == 0)
    {
        if ( indexPath.row == 0)
            cell.textLabel.text = @"Sponsors";
        if ( indexPath.row == 1)
            cell.textLabel.text = @"Donate today!";
    }
    
    if ( indexPath.section == 1)
    {
        if ( indexPath.row == 0)
            cell.textLabel.text = @"Settings";
    }
    if ( indexPath.section == 2)
    {
        if ( indexPath.row == 0)
            cell.textLabel.text = @"About PD";
        if ( indexPath.row == 1)
            cell.textLabel.text = @"About the app";
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
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
<<<<<<< HEAD
//        PDDonations
=======
        if (indexPath.row==1) {
            PDDonationsViewController *donationsViewController = [[PDDonationsViewController alloc] initWithNibName:@"PDDonationsViewController" bundle:nil];
            [self.navigationController pushViewController:donationsViewController animated:YES];
        }
>>>>>>> 01a3405c7e4b11614fa29774f259e7fde5e65962
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if ( section == 0)
        return @"Sponsors";
    
    if ( section == 1)
        return @"Settings";
    
    if ( section == 2)
        return @"About";

    return  nil;
}

@end
