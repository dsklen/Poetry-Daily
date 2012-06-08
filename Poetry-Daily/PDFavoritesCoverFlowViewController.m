//
//  PDFavoritesCoverFlowViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/4/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDFavoritesCoverFlowViewController.h"
#import "PDFavoriteView.h"

#define ITEM_SIZE 200.0f

@interface PDFavoritesCoverFlowViewController ()
- (void)reloadData;
- (void)loadMediaItems:(NSArray *)newItems;

@end

@implementation PDFavoritesCoverFlowViewController


#pragma mark Properties

@synthesize carousel = _carousel;
@synthesize favorites = _favorites;

#pragma mark Private API

- (void)reloadData;
{
    //    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MediaItem"];
    //    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] init];
    //    
    //    request.predicate = self.fetchPredicate;
    //    request.fetchOffset = 0;
    //    request.fetchLimit = NUMBER_OF_VISIBLE_ITEMS;
    //    
    //    [serverInfo setObject:[NSNumber numberWithInteger:TVServerCommandHomeRow] forKey:TVServerCommandKey];
    //    [serverInfo setObject:self.serverKey forKey:TVHomeRowCategoryKey];
    //    
    //    TVCachedDataController *controller = [TVCachedDataController sharedDataController];
    //    NSArray *items = [controller fetchObjects:request serverInfo:serverInfo cacheUpdateBlock:^(NSArray *newResults) { [self loadMediaItems:newResults]; }];
    //    
    //    [self loadMediaItems:items];
}

- (void)loadMediaItems:(NSArray *)newItems;
{
    
}

#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated;
{
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.carousel.accessibilityLabel = self.title;
    self.carousel.stopAtItemBoundary = YES;
    self.carousel.type = iCarouselTypeLinear;
    self.carousel.contentOffset = CGSizeMake( 0.0f, 0.0f );

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.carousel = nil;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}


#pragma mark iCarouselDataSource

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 10; // [self.favorites count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	if ( view == nil )
        view = [[PDFavoriteView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, ITEM_SIZE, ITEM_SIZE + 30.0f )];
    
//    ((PDFavoriteView *)view).mediaItem = [self.favorites objectAtIndex:index];
    
	return view;
}   

#pragma mark iCarouselDelegate

- (BOOL)carouselShouldWrap:(iCarousel *)carousel;
{
    return NO;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    return 10; //[self.favorites count];
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return ITEM_SIZE;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index;
{
//    TVMediaItem *mediaItem = [self.mediaItems objectAtIndex:index];
//    [[NSNotificationCenter defaultCenter] postNotificationName:TVSelectedMediaItemNotification object:mediaItem];
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view;
{
    return nil;
}

@end
