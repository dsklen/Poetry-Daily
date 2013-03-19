//
//  PDFeatureViewController.m
//  Poetry-Daily
//
//  Created by David Sklenar on 3/6/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDFeatureViewController.h"
#import "SVProgressHUD.h"
#import "PDMediaServer.h"


@interface PDFeatureViewController ()

@end

@implementation PDFeatureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [SVProgressHUD showWithStatus:@"Loading..."];
    
    PDMediaServer *server = [[PDMediaServer alloc] init];
    
    [server fetchFeatureWithID:self.poemID block:^(NSArray *items, NSError *error) {
        
        if ( items && !error)
        {
            NSDictionary *featureAttributesDictionary = [items lastObject];
            
            NSString *poetInfo = [featureAttributesDictionary objectForKey:@"poetLT"];
            NSString *journalInfo = [featureAttributesDictionary objectForKey:@"jText"];
            
            NSMutableString *HTML = [[NSMutableString alloc] init];
            
            [HTML appendString:[NSString stringWithFormat:@"<html><head><style type=\"text/css\"> body {font-family:helvetica,sans-serif; font-size: 20px;  white-space:normal; padding:0px; margin:0px;}</style></head><body>"]];
            NSString *combinedInfo = [NSString stringWithFormat:@"%@<br><br>%@", poetInfo, journalInfo];
            
            [HTML appendString:combinedInfo];
            [HTML appendString:@"</body></html>"];
            
            [self.featureInformationWebView loadHTMLString:combinedInfo baseURL:nil];
                        
            NSString *publisherName = [featureAttributesDictionary objectForKey:@"publisher"];
            NSString *pubURLString = [featureAttributesDictionary objectForKey:@"puburl"];
//            self.iPadVisitPublicationPageButton.hidden = ( [pubURLString length] == 0 );
            
//            [self.iPadVisitPublicationPageButton setTitle:[NSString stringWithFormat:@"Visit %@ Site ⇗", ([publisherName length] == 0 ) ? @"Publisher" : publisherName] forState:UIControlStateNormal];
        
            [SVProgressHUD dismiss];
        }
        else
            [SVProgressHUD dismissWithError:@"Failed to load"];

    }];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
