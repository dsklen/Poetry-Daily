//
//  PDDonationsViewController.h
//  Poetry-Daily
//
//  Created by Lyle Boller on 3/1/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@class NWPickerField;

typedef enum PaymentStatuses {
	PAYMENTSTATUS_SUCCESS,
	PAYMENTSTATUS_FAILED,
	PAYMENTSTATUS_CANCELED,
} PaymentStatus;

@interface PDDonationsViewController : UIViewController <PayPalPaymentDelegate, UITextFieldDelegate, NSURLConnectionDataDelegate>
{
@private
	IBOutlet UITextField *amount;
	CGFloat y;
	BOOL resetScrollView;
}

@property (nonatomic, strong) NSString *environment;
@property (nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property (nonatomic, strong, readwrite) PayPalPayment *completedPayment;
@property (nonatomic, strong) IBOutlet UIButton *payButton;
@property (nonatomic, strong) IBOutlet UIView *successView;

- (IBAction)showPayPalInSafari:(id)sender;


@end