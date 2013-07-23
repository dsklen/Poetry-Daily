//
//  ISRevealControllerViewController.m
//
//
//

#import "ISRevealController.h"

@interface ISRevealController ()


@end

@implementation ISRevealController


#pragma mark - ZUUIRevealControllerDelegate

/*
 * All of the methods below are optional. You can use them to control the behavior of the ZUUIRevealController,
 * or react to certain events.
 */



- (void)hideModal:(NSNotification *)notification;
{
    if ( [self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)] )
        [self dismissViewControllerAnimated:YES completion:^{}];
    else
        [self dismissModalViewControllerAnimated:YES];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)revealController:(ZUUIRevealController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController
{
	return YES;
}

- (BOOL)revealController:(ZUUIRevealController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController
{
	return YES;
}

- (void)revealController:(ZUUIRevealController *)revealController willRevealRearViewController:(UIViewController *)rearViewController
{
    //	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didRevealRearViewController:(UIViewController *)rearViewController
{    
    //	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController willHideRearViewController:(UIViewController *)rearViewController
{
    //	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didHideRearViewController:(UIViewController *)rearViewController
{            
    //	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController willResignRearViewControllerPresentationMode:(UIViewController *)rearViewController
{
    //	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didResignRearViewControllerPresentationMode:(UIViewController *)rearViewController
{
    //	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController willEnterRearViewControllerPresentationMode:(UIViewController *)rearViewController
{
    //	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didEnterRearViewControllerPresentationMode:(UIViewController *)rearViewController
{
    //	NSLog(@"%@", NSStringFromSelector(_cmd));
}


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
    if ( self )
    {
        self.delegate = self;
        

    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated;
{
 }

- (void)dealloc;
{
}


- (NSUInteger)supportedInterfaceOrientations
{    
    return UIInterfaceOrientationMaskAll;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{    
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
{    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{

}



@end
