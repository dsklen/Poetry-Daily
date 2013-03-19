//
//  PDDonationsViewController.h
//  Poetry-Daily
//
//  Created by Lyle Boller on 3/1/13.
//  Copyright (c) 2013 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPal.h"

typedef enum PaymentStatuses {
	PAYMENTSTATUS_SUCCESS,
	PAYMENTSTATUS_FAILED,
	PAYMENTSTATUS_CANCELED,
} PaymentStatus;

@interface PDDonationsViewController : UIViewController <PayPalPaymentDelegate, UITextFieldDelegate> {
@private
	IBOutlet UITextField *amount;
	CGFloat y;
	BOOL resetScrollView;
	PaymentStatus status;
}

@property (nonatomic, retain) IBOutlet UITextField *amount;

@end