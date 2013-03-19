//
//  EmailSignUpViewController.h
//  PD3
//
//  Created by David Sklenar on 2/3/10.
//

#import <UIKit/UIKit.h>


@interface EmailSignUpViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIAlertViewDelegate> {
	UITextField *emailAddressField;
	UIWebView *webView;
	NSString *email;
	UILabel *success;
	UILabel *failure;
}

@property (nonatomic, retain) IBOutlet UITextField *emailAddressField;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *success;
@property (nonatomic, retain) IBOutlet UILabel *failure;
@property (nonatomic, retain) NSString *email;

-(IBAction)submitEmail;

@end
