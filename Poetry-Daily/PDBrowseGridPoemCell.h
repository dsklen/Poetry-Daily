//
//  PDBrowseGridPoemCell.h
//  Poetry-Daily
//
//  Created by David Sklenar on 3/26/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionViewCell.h"
#import "PSTCollectionView.h"

@interface PDBrowseGridPoemCell : PSUICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) NSString *poemID;

- (void)tapped:(UITapGestureRecognizer *)recognizer;


@end
