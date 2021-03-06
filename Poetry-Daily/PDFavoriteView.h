//
//  PDFavoriteView.h
//  Poetry-Daily
//
//  Created by David Sklenar on 6/4/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDPoem;

@interface PDFavoriteView : UIView

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *publishedDateLabel;
@property (nonatomic, strong) UIButton *favoriteButton;

@property (nonatomic, strong) PDPoem *poem;

- (IBAction)favoriteOrUnfavorite:(id)sender;

@end
