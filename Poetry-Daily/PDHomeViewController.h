//
//  PDHomeViewController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 5/24/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDPoem;

@interface PDHomeViewController : UIViewController

@property (strong, nonatomic) PDPoem *currentPoem;
@property (strong, nonatomic) IBOutlet UILabel *poemPublishedDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *poemTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *poemAuthorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *poemAuthorImageView;
@property (strong, nonatomic) IBOutlet UIButton *readPoemButton;

- (IBAction)showMainPoemView:(id)sender;

@end
