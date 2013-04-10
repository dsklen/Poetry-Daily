//
//  PDDonationsViewController.m
//  Poetry-Daily
//
//  Created by Lyle Boller on 3/1/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDDonationsViewController.h"

#define SPACING 3.

@interface PDDonationsViewController ()

@property (strong, nonatomic) NSArray *donationAmountsArray;
- (IBAction)tappedView:(id)sender;
- (NSData *)encodedDataFromDictionary:(NSDictionary *)dictionary;

@end

@implementation PDDonationsViewController


#define kPayPalClientId @"AcXlqhDvy2jNcHDI7T5-Rug67gzPB1yqFR4wxmMFBLYS3qRrbKy-2qKMDSz9"
#define kPayPalReceiverEmail @"staff-facilitator@poems.com"

#pragma mark -
#pragma mark Utility methods

- (UITextField *)addTextFieldWithPlaceholder:(NSString *)placeholder;
{
	CGFloat width = 294.;
	CGFloat x = round((self.view.frame.size.width - width) / 2.);
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width, 30.)];
	textField.placeholder = placeholder;
	textField.font = [UIFont systemFontOfSize:14.];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = self;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[self.view addSubview:textField];
	
	y += 30. + SPACING;
	
	return textField;
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad;
{
    self.title = @"Donate";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_new"]];
	
	y = 2.;

    self.acceptCreditCards = YES;
    self.environment = PayPalEnvironmentSandbox;

    self.donationAmountsArray = @[@"$20.00", @"$5.00", @"$10.00", @"$25.00", @"$50.00", @"$100.00", @"$200.00", @"$500.00"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedView:)];
    [self.view addGestureRecognizer:tap];
    
//    [self.amount selectRow:3 inComponent:0 animated:NO];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:YES];
    
    UIEdgeInsets insets = UIEdgeInsetsMake( 0.0f, 15.0f, 0, 14.0f );
    UIImage *payBackgroundImage = [[UIImage imageNamed:@"button_secondary.png"] resizableImageWithCapInsets:insets];
    UIImage *payBackgroundImageHighlighted = [[UIImage imageNamed:@"button_secondary_selected.png"] resizableImageWithCapInsets:insets];
    [self.payButton setBackgroundImage:payBackgroundImage forState:UIControlStateNormal];
    [self.payButton setBackgroundImage:payBackgroundImageHighlighted forState:UIControlStateHighlighted];
//    [self.payButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.payButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    // Optimization: Prepare for display of the payment UI by getting network work done early
    [PayPalPaymentViewController setEnvironment:self.environment];
    [PayPalPaymentViewController prepareForPaymentUsingClientId:kPayPalClientId];
}

- (void)viewWillDisappear:(BOOL)animated;
{
}

- (IBAction)tappedView:(id)sender;
{
    return;
}

- (IBAction)showPayPalInSafari:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=staff%40poems%2ecom&lc=US&item_name=The%20Daily%20Poetry%20Association%20%28Poetry%20Daily%29&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest"]];
    
    return;
    
    NSMutableString *URLString = [NSMutableString stringWithString:@"https://www.paypal.com/cgi-bin/webscr"];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSLog(@"%@", URLString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    
    
    NSMutableDictionary *mutableParams = [[NSMutableDictionary alloc] init];
    [mutableParams setObject:@"_donations" forKey:@"cmd"];
    [mutableParams setObject:@"staff@poems.com" forKey:@"business"];
    [mutableParams setObject:@"The Daily Poetry Association (Poetry Daily)" forKey:@"item_name"];
    [mutableParams setObject:@"0" forKey:@"no_shipping"];
    [mutableParams setObject:@"http://www.poems.com/" forKey:@"return"];
    [mutableParams setObject:@"Premium Selection" forKey:@"cn"];
    [mutableParams setObject:@"USD" forKey:@"currency_code"];
    [mutableParams setObject:@"0" forKey:@"tax"];
    [mutableParams setObject:@"US" forKey:@"lc"];
    [mutableParams setObject:@"PP-DonationsBF" forKey:@"bn"];

    [request setHTTPMethod:@"post"];
    [request setHTTPBody:[self encodedDataFromDictionary:mutableParams]];
    

    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (NSData *)encodedDataFromDictionary:(NSDictionary *)dictionary;
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    for ( NSString *key in [dictionary allKeys] )
    {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    
    NSString *encodedDictionaryString = [parts componentsJoinedByString:@"&"];
    
    return [encodedDictionaryString dataUsingEncoding:NSUTF8StringEncoding];
}


- (IBAction)pay;
{    
    // Remove our last completed payment, just for demo purposes.
    self.completedPayment = nil;
    
    NSMutableString *amountString;// = [NSMutableString stringWithString:self.amount.text];
    
    if ( amountString.length == 0 )
        return;

    [amountString replaceOccurrencesOfString:@"$" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, amountString.length)];
    
    if ( amountString.length == 0 )
        return;
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:amountString];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Donation Amount";
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Any customer identifier that you have will work here. Do NOT use a device- or
    // hardware-based identifier.
    NSString *customerId = @"user-11723";
    
    // Set the environment:
    // - For live charges, use PayPalEnvironmentProduction (default).
    // - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
    // - For testing, use PayPalEnvironmentNoNetwork.
    [PayPalPaymentViewController setEnvironment:self.environment];
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:kPayPalClientId
                                                                                                 receiverEmail:kPayPalReceiverEmail
                                                                                                       payerId:customerId
                                                                                                       payment:payment
                                                                                                      delegate:self];
    paymentViewController.hideCreditCardButton = !self.acceptCreditCards;
    
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark - Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}


#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment;
{
    NSLog(@"PayPal Payment Success!");
    self.completedPayment = completedPayment;
    self.successView.hidden = NO;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your Support" message:@"Thank you for supporting Poetry Daily!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel;
{
    NSLog(@"PayPal Payment Canceled");
    self.completedPayment = nil;
    self.successView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	[textField resignFirstResponder];
	return TRUE;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
	resetScrollView = FALSE;
	return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
	resetScrollView = TRUE;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationBeginsFromCurrentState:TRUE];
	self.view.frame = CGRectMake(0., -216., self.view.frame.size.width, self.view.frame.size.height);
	[UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
	if (resetScrollView) {
		resetScrollView = FALSE;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:.3];
		[UIView setAnimationBeginsFromCurrentState:TRUE];
		self.view.frame = CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height);
		[UIView commitAnimations];
	}
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return TRUE;
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerField:(NWPickerField *)pickerField;
{
    return 1;
}

- (NSInteger)pickerField:(NWPickerField *)pickerField numberOfRowsInComponent:(NSInteger)component;
{
    return [self.donationAmountsArray count];
}

- (NSString *)pickerField:(NWPickerField *)pickerField titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{    
//    if ( row == 0 )
//    {
//        return [NSString stringWithFormat:@"%@ - recommended", [self.donationAmountsArray objectAtIndex:row]];
//    }
    
    return [self.donationAmountsArray objectAtIndex:row];
}


#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

-(NSUInteger)supportedInterfaceOrientations;
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
{
    NSLog(@"Redirect %@", [request URL]);
    NSLog(@"RedirectRespone %@", redirectResponse);

//    [[UIApplication sharedApplication] openURL:[request URL]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    NSLog(@"%@",[connection currentRequest]);

}


@end
