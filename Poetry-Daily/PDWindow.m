//
//  PDWindow.m
//  Poetry-Daily
//
//  Created by David Sklenar on 6/11/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import "PDWindow.h"

@implementation PDWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self becomeFirstResponder];
    }
    return self;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
{
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) 
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceShaken" object:self];
        [self becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated;
{
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder;
{
    return YES;
}

@end
