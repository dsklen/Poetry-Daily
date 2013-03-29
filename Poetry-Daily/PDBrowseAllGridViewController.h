//
//  PDBrowseAllGridViewController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 3/26/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "PDBrowseAllPoemsViewController.h"


@interface PDBrowseAllGridViewController : PSUICollectionViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *poemsArray;
@property (strong, nonatomic) NSMutableArray *displayPoemsArray;
@property (strong, nonatomic) NSMutableArray *filteredPoemsArray;
@property (strong, nonatomic) UISearchDisplayController *searchController;

@property (assign, nonatomic) PDShowPoemsMode poemsMode;


@end
