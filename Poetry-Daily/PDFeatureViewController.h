//
//  PDFeatureViewController.h
//  Poetry-Daily
//
//  Created by David Sklenar on 3/6/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFeatureViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *featureInformationWebView;
@property (strong, nonatomic) NSString *poemID;

@end
