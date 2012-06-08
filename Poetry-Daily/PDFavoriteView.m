//
//  PDFavoriteView.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/4/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDFavoriteView.h"
#import <QuartzCore/QuartzCore.h>


@implementation PDFavoriteView

#pragma mark - Properties

@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize titleLabel = _titleLabel;
@synthesize authorLabel = _authorLabel;
@synthesize publishedDateLabel = _publishedDateLabel;
@synthesize favoriteButton = _favoriteButton;


#pragma mark - API

- (IBAction)favoriteOrUnfavorite:(id)sender;
{
    UIButton *senderButton = (UIButton *)sender;
    
    if (senderButton.imageView.image == [UIImage imageNamed:@"favoriteStar"])
        [senderButton setImage:[UIImage imageNamed:@"unfilledFavoriteStar"] forState:UIControlStateNormal];
    else
        [senderButton setImage:[UIImage imageNamed:@"favoriteStar"] forState:UIControlStateNormal];
}

#pragma mark - View Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) 
    {
        _thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 27.5f, 0.0f, 145.0f, 200.0f )];
        _thumbnailImageView.image = [UIImage imageNamed:@"plumlystanley.jpeg"];
        _thumbnailImageView.clipsToBounds = YES;
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.userInteractionEnabled = NO;
        _thumbnailImageView.backgroundColor = [UIColor whiteColor];
        
        // Made some changes to fix performance trouble on iPad 1. Still need 
        // to profile the app in Instruments to see exactly what issues remain.
        
        _thumbnailImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _thumbnailImageView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
        _thumbnailImageView.layer.shadowRadius = 2.0f;
        _thumbnailImageView.layer.shadowOpacity = 0.5f;
        _thumbnailImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _thumbnailImageView.layer.borderWidth = 2.0f;
        _thumbnailImageView.layer.shouldRasterize = YES;
        _thumbnailImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.5f, 155.0f, 135.0f, 20.0f)];
        _titleLabel.text = @"A Poem";
        _titleLabel.textAlignment = UITextAlignmentRight;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:11];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.5f, 175.0f, 135.0f, 20.0f)];
        _authorLabel.text = @"The Author";
        _authorLabel.textAlignment = UITextAlignmentRight;
        _authorLabel.textColor = [UIColor blackColor];
        _authorLabel.font = [UIFont boldSystemFontOfSize:11];
        _authorLabel.backgroundColor = [UIColor clearColor];
        
        _publishedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 205.0f, frame.size.width, 20.0f)];
        _publishedDateLabel.text = @"June 3, 2012";
        _publishedDateLabel.textAlignment = UITextAlignmentCenter;
        _publishedDateLabel.textColor = [UIColor whiteColor];
        _publishedDateLabel.font = [UIFont boldSystemFontOfSize:11];
        _publishedDateLabel.backgroundColor = [UIColor clearColor];
        
        _favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(27.5f, 205.0f, 20.0f, 20.0f)];
        [_favoriteButton setImage:[UIImage imageNamed:@"favoriteStar"] forState:UIControlStateNormal];
        _favoriteButton.contentMode = UIViewContentModeCenter;
        [_favoriteButton addTarget:self action:@selector(favoriteOrUnfavorite:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_thumbnailImageView];
        [self addSubview:_titleLabel];
        [self addSubview:_authorLabel];
        [self addSubview:_publishedDateLabel];
        [self addSubview:_favoriteButton];
    }
    return self;
}


@end
