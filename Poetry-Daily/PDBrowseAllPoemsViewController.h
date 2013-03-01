//
//  PDBrowseAllPoemsViewController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 6/4/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
    PDShowPoemsModeAll = 0,
    PDShowPoemsModeFavoritesOnly,
} PDShowPoemsMode;


@interface PDBrowseAllPoemsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>

@property (readwrite, nonatomic) BOOL isShowingLandscapeView;

@property (strong, nonatomic) NSMutableArray *poemsArray;
@property (strong, nonatomic) NSMutableArray *displayPoemsArray;
@property (strong, nonatomic) NSMutableArray *filteredPoemsArray;
@property (strong, nonatomic) IBOutlet UITableView *poemsTableView;
@property (strong, nonatomic) UISearchDisplayController *searchController;

@property (assign, nonatomic) PDShowPoemsMode poemsMode;

@end
