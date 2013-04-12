//
//  PDBrowseGridPoemCell.m
//  Poetry-Daily
//
//  Created by David Sklenar on 3/26/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDBrowseGridPoemCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PDBrowseGridPoemCell

- (id)initWithFrame:(CGRect)frame;
{
    if ( self = [super initWithFrame:frame] );
    {
        self.backgroundColor = [UIColor whiteColor];
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 80.0f, 106.6f)];
//            imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = NO;
            imageView.layer.shadowColor = [UIColor blackColor].CGColor;
            imageView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
            imageView.layer.shadowRadius = 2.0f;
            imageView.layer.shadowOpacity = 0.5f;
            imageView.layer.shouldRasterize = YES;
            imageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
            [self.contentView addSubview:imageView];
            _imageView = imageView;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 140.0, 105.0f, 20.0f)];
            titleLabel.numberOfLines = 0;
    //        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            titleLabel.textAlignment = UITextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
            titleLabel.textColor = [UIColor darkGrayColor];        
            [self.contentView addSubview:titleLabel];
            _titleLabel = titleLabel;
            
            UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 140.0, frame.size.width, 20.0f)];
            subtitleLabel.textAlignment = UITextAlignmentCenter;
            subtitleLabel.font = [UIFont systemFontOfSize:11.0];
            subtitleLabel.textColor = [UIColor darkGrayColor];
            [self.contentView addSubview:subtitleLabel];
            _subtitleLabel = subtitleLabel;
        }
        else
        {
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 160.0f, 213.6f)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = NO;
            imageView.layer.shadowColor = [UIColor blackColor].CGColor;
            imageView.layer.shadowOffset = CGSizeMake( 0.0f, 1.0f );
            imageView.layer.shadowRadius = 2.0f;
            imageView.layer.shadowOpacity = 0.5f;
            imageView.layer.shouldRasterize = YES;
            imageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
            [self.contentView addSubview:imageView];
            _imageView = imageView;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 225.0, 210.0f, 20.0f)];
            titleLabel.numberOfLines = 0;
            //        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            titleLabel.textAlignment = UITextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
            titleLabel.textColor = [UIColor darkGrayColor];
            [self.contentView addSubview:titleLabel];
            _titleLabel = titleLabel;
            
            UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 245.0, frame.size.width, 20.0f)];
            subtitleLabel.textAlignment = UITextAlignmentCenter;
            subtitleLabel.font = [UIFont systemFontOfSize:11.0];
            subtitleLabel.textColor = [UIColor darkGrayColor];
            [self.contentView addSubview:subtitleLabel];
            _subtitleLabel = subtitleLabel;
        }
            
        _poemID = [[NSString alloc] init];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)tapped:(UITapGestureRecognizer *)recognizer;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PDOpenPoemFromGrid" object:self.poemID];
}


@end
