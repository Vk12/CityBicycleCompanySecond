//
//  ShippingViewController.m
//  CityBicycleCompany
//
//  Created by May Yang on 12/21/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "ShippingViewController.h"
#import "Cart.h"
#import "ChosenAccessory.h"
#import "ChosenBike.h"
#import <Parse/Parse.h>
#import "PaymentViewController.h"
#define MAX_LENGTH 20

@interface ShippingViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property UIGestureRecognizer *tapper;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityStateTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;
@property NSMutableArray *shippingInfo;

@end

@implementation ShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // add extra spaces between Total: and %@
    self.priceLabel.text = [NSString stringWithFormat:@"Total: %*s %@", 5, "", self.subtotal];
    
    self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.tapper setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:self.tapper];
    
    self.shippingInfo = [NSMutableArray new];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}



- (IBAction)checkoutButtonTapped:(UIButton *)sender
{
    NSString *nameString = self.nameTextField.text;
    NSString *emailString = self.emailTextField.text;
    NSString *addressString = self.addressTextField.text;
    NSString *cityStateString = self.cityStateTextField.text;
    NSString *postalCodeString = self.postalCodeTextField.text;
    [self.shippingInfo addObject:nameString];
    [self.shippingInfo addObject:emailString];
    [self.shippingInfo addObject:addressString];
    [self.shippingInfo addObject:cityStateString];
    [self.shippingInfo addObject:postalCodeString];
    
    
    if (!self.nameTextField.text.length > 0)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill in a name.", @"Please fill in all fields") message:NSLocalizedString(@"", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil] show];
    }
    else if (!self.emailTextField.text.length > 0)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill in an email address.", @"Please fill in all fields") message:NSLocalizedString(@"", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil] show];
        
        
    }
    else if (!self.addressTextField.text.length > 0)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill in an address.", @"Please fill in all fields") message:NSLocalizedString(@"", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil] show];
    }
    else if (!self.cityStateTextField.text.length > 0)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill in a city and state.", @"Please fill in all fields") message:NSLocalizedString(@"", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil] show];
    }

    else if (!([self.postalCodeTextField.text length] == 5))
    {
        
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill in a valid postal code.", @"Please fill in all fields") message:NSLocalizedString(@"Must be 5 digits", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil] show];
        
    }
    else if (self.emailTextField.text.length > 0)
    {
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        // If valid address
        if ([emailTest evaluateWithObject:self.emailTextField.text] == YES)
        {
            [self popToPaymentVC];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill in a valid email address.", @"Please fill in all fields") message:NSLocalizedString(@"", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil] show];
        }
    }
    else
    {
        [self popToPaymentVC];
    }

    
}


- (IBAction)onXDismissedPressed:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)isEmailValid:(NSString *)email
{
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"];
    return [regex evaluateWithObject:email];
}

- (void)popToPaymentVC
{
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    
    //    Convert subtotal (string) to NSDecimalNumber. Pass to paymentViewController.
    paymentViewController.amount = [NSDecimalNumber decimalNumberWithString:self.subtotal];
    
    // pass array to paymentViewController.
    paymentViewController.shippingInfo = self.shippingInfo;
    
    [self presentViewController:navController animated:YES completion:nil];
 }



@end
