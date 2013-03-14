//
//  PDMoreViewController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 6/8/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface PDMoreViewController : UITableViewController<iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) IBOutlet UITableViewCell *sponsorsTableViewCell;
@property (nonatomic, strong) NSMutableArray *sponsors;
@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@end
