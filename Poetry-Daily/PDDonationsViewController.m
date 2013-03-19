//
//  PDDonationsViewController.m
//  Poetry-Daily
//
//  Created by Lyle Boller on 3/1/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import "PDDonationsViewController.h"
#import "PayPalPayment.h"
#import "PayPalAdvancedPayment.h"
#import "PayPalAmounts.h"
#import "PayPalReceiverAmounts.h"
#import "PayPalAddress.h"
#import "PayPalInvoiceItem.h"
#import "PayPal.h"
#import "SuccessViewController.h"

#define SPACING 3.

@interface PDDonationsViewController ()

@end

@implementation PDDonationsViewController

@synthesize amount;

#pragma mark -
#pragma mark Utility methods

- (void)addLabelWithText:(NSString *)text andButtonWithType:(PayPalButtonType)type withAction:(SEL)action {
	UIFont *font = [UIFont boldSystemFontOfSize:10.];
	CGSize size = [text sizeWithFont:font];
	
	//you should call getPayButton to have the library generate a button for you.
	//this button will be disabled if device interrogation fails for any reason.
	//
	//-- required parameters --
	//target is a class which implements the PayPalPaymentDelegate protocol.
	//action is the selector to call when the button is clicked.
	//inButtonType is the button type (desired size).
	//
	//-- optional parameter --
	//inButtonText can be either BUTTON_TEXT_PAY (default, displays "Pay with PayPal"
	//in the button) or BUTTON_TEXT_DONATE (displays "Donate with PayPal" in the
	//button). the inButtonText parameter also affects some of the library behavior
	//and the wording of some messages to the user.
	UIButton *button = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:action andButtonType:type andButtonText:BUTTON_TEXT_DONATE];
	CGRect frame = button.frame;
	frame.origin.x = round((self.view.frame.size.width - button.frame.size.width) / 2.);
	frame.origin.y = 375.0f;// round(y + size.height);
	button.frame = frame;
	[self.view addSubview:button];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, y, size.width, size.height)];
	label.font = font;
	label.text = text;
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	
	y += size.height + frame.size.height + SPACING;
}

- (UITextField *)addTextFieldWithPlaceholder:(NSString *)placeholder {
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

- (void)addAppInfoLabel {
	NSString *text = [NSString stringWithFormat:@"Library Version: %@\nDemo App Version: %@",
					  [PayPal buildVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	UIFont *font = [UIFont systemFontOfSize:14.];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(self.view.frame.size.width, MAXFLOAT)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(round((self.view.frame.size.width - size.width) / 2.), y, size.width, size.height)];
	label.font = font;
	label.text = text;
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
}


#pragma mark -
#pragma mark View lifecycle methods

- (void)viewDidLoad;
{
    self.title = @"Donate";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_new"]];

    [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];

    status = PAYMENTSTATUS_CANCELED;
	
	y = 2.;
	
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //	button.frame = CGRectMake((self.view.frame.size.width - 125), 2, 75, 25);
    //
    //	[button setTitle:@"Retry Init" forState:UIControlStateNormal];
    //	[button addTarget:self action:@selector(RetryInitialization) forControlEvents:UIControlEventTouchUpInside];
    //	[self.view addSubview:button];
    
	[self addLabelWithText:nil andButtonWithType:BUTTON_294x43 withAction:@selector(simplePayment)];

}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
//    [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
////	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
//	self.view.autoresizesSubviews = YES;
//	UIColor *color = [UIColor groupTableViewBackgroundColor];
//	if (CGColorGetPattern(color.CGColor) == NULL) {
//		color = [UIColor lightGrayColor];
//	}
//	self.view.backgroundColor = color;
//	self.title = @"Donate";
//	
//	status = PAYMENTSTATUS_CANCELED;
//	
//	y = 2.;
//	
////    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
////	button.frame = CGRectMake((self.view.frame.size.width - 125), 2, 75, 25);
////    
////	[button setTitle:@"Retry Init" forState:UIControlStateNormal];
////	[button addTarget:self action:@selector(RetryInitialization) forControlEvents:UIControlEventTouchUpInside];
////	[self.view addSubview:button];
//    
//	[self addLabelWithText:nil andButtonWithType:BUTTON_294x43 withAction:@selector(simplePayment)];
////	[self addLabelWithText:@"Parallel Payment" andButtonWithType:BUTTON_294x43 withAction:@selector(parallelPayment)];
////	[self addLabelWithText:@"Chained Payment" andButtonWithType:BUTTON_294x43 withAction:@selector(chainedPayment)];
////	[self addLabelWithText:@"Preapproval" andButtonWithType:BUTTON_294x43 withAction:@selector(preapproval)];
//	
////	self.preapprovalField = [self addTextFieldWithPlaceholder:@"Preapproval Key"];
//	
////	[self addAppInfoLabel];
//}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Actions triggered by Pay with PayPal buttons

- (void)simplePayment {
	//dismiss any native keyboards
	[amount resignFirstResponder];
	
	//optional, set shippingEnabled to TRUE if you want to display shipping
	//options to the user, default: TRUE
	[PayPal getPayPalInst].shippingEnabled = FALSE;
	
	//optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	//shipping and tax based on the user's address choice, default: FALSE
	[PayPal getPayPalInst].dynamicAmountUpdateEnabled = FALSE;
	
	//optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
	[PayPal getPayPalInst].feePayer = FEEPAYER_EACHRECEIVER;
	
	//for a payment with a single recipient, use a PayPalPayment object
	PayPalPayment *payment = [[PayPalPayment alloc] init];
	payment.recipient = @"staff@poems.com";
	payment.paymentCurrency = @"USD";
	payment.description = @"PD Contribution";
	payment.merchantName = @"The Daily Poetry Association (Poetry Daily)";
	
	//subtotal of all items, without tax and shipping
    if (amount.text) {
        payment.subTotal = [NSDecimalNumber decimalNumberWithString:amount.text];
        
        //invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
        payment.invoiceData = [[PayPalInvoiceData alloc] init];
        payment.invoiceData.totalShipping = [NSDecimalNumber decimalNumberWithString:@"0"];
        payment.invoiceData.totalTax = [NSDecimalNumber decimalNumberWithString:@"0"];
        
        //invoiceItems is a list of PayPalInvoiceItem objects
        //NOTE: sum of totalPrice for all items must equal payment.subTotal
        //NOTE: example only shows a single item, but you can have more than one
        payment.invoiceData.invoiceItems = [NSMutableArray array];
        PayPalInvoiceItem *item = [[PayPalInvoiceItem alloc] init];
        item.totalPrice = payment.subTotal;
        item.name = @"PD Contribution";
        [payment.invoiceData.invoiceItems addObject:item];
        
        [[PayPal getPayPalInst] checkoutWithPayment:payment];
    }
    
    else{
        //Prompt user to enter in a donation amount
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Donation" message:@"Please enter a Donation Amount" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
        
    }
}

#pragma mark -
#pragma mark PayPalPaymentDelegate methods

-(void)RetryInitialization
{
    [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
    
    //DEVPACKAGE
    //	[PayPal initializeWithAppID:@"your live app id" forEnvironment:ENV_LIVE];
    //	[PayPal initializeWithAppID:@"anything" forEnvironment:ENV_NONE];
}

//paymentSuccessWithKey:andStatus: is a required method. in it, you should record that the payment
//was successful and perform any desired bookkeeping. you should not do any user interface updates.
//payKey is a string which uniquely identifies the transaction.
//paymentStatus is an enum value which can be STATUS_COMPLETED, STATUS_CREATED, or STATUS_OTHER
- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus {
    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
	NSLog(@"severity: %@", severity);
	NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
	NSLog(@"category: %@", category);
	NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
	NSLog(@"errorId: %@", errorId);
	NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
	NSLog(@"message: %@", message);
    
	status = PAYMENTSTATUS_SUCCESS;
}

//paymentFailedWithCorrelationID is a required method. in it, you should
//record that the payment failed and perform any desired bookkeeping. you should not do any user interface updates.
//correlationID is a string which uniquely identifies the failed transaction, should you need to contact PayPal.
//errorCode is generally (but not always) a numerical code associated with the error.
//errorMessage is a human-readable string describing the error that occurred.
- (void)paymentFailedWithCorrelationID:(NSString *)correlationID {
    
    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
	NSLog(@"severity: %@", severity);
	NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
	NSLog(@"category: %@", category);
	NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
	NSLog(@"errorId: %@", errorId);
	NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
	NSLog(@"message: %@", message);
    
	status = PAYMENTSTATUS_FAILED;
}

//paymentCanceled is a required method. in it, you should record that the payment was canceled by
//the user and perform any desired bookkeeping. you should not do any user interface updates.
- (void)paymentCanceled {
	status = PAYMENTSTATUS_CANCELED;
}

//paymentLibraryExit is a required method. this is called when the library is finished with the display
//and is returning control back to your app. you should now do any user interface updates such as
//displaying a success/failure/canceled message.
- (void)paymentLibraryExit {
	UIAlertView *alert = nil;
	switch (status) {
		case PAYMENTSTATUS_SUCCESS:
			[self.navigationController pushViewController:[[SuccessViewController alloc] init] animated:TRUE];
			break;
		case PAYMENTSTATUS_FAILED:
			alert = [[UIAlertView alloc] initWithTitle:@"Order failed"
											   message:@"Your order failed. Touch \"Pay with PayPal\" to try again."
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			break;
		case PAYMENTSTATUS_CANCELED:
			alert = [[UIAlertView alloc] initWithTitle:@"Order canceled"
											   message:@"You canceled your order. Touch \"Pay with PayPal\" to try again."
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			break;
	}
	[alert show];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return TRUE;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	resetScrollView = FALSE;
	return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	resetScrollView = TRUE;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationBeginsFromCurrentState:TRUE];
	self.view.frame = CGRectMake(0., -216., self.view.frame.size.width, self.view.frame.size.height);
	[UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
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



@end
