//
//  PaymentViewController.m
//  CityBicycleCompany
//
//  Created by May Yang on 12/15/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "PaymentViewController.h"
#import "Stripe.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "PTKAddressZip.h"
#import "Cart.h"
#import "ChosenAccessory.h"

@interface PaymentViewController ()
@property NSString *bikeName;
@property NSString *bikeSize;
@property BOOL bicycleHasRearBrake;
@property NSString *bikeWheelSetColor;
@property NSString *bikeExtraWheelset;
@property NSNumber *bikeQty;
@property NSString *shippingName;
@property NSString *email;
@property NSString *shippingAddress;
@property NSString *cityState;
@property NSString *zipcode;
@property NSString *accessoryName;
@property NSNumber *accessoryQty;
@property NSString *accessoryColor;
@property NSString *accessorySize;
@property NSMutableArray *lineItems;

@end

@implementation PaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Checkout";
    
    // Sets textfield below the navigation bar
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Centers payment textfield in view
    float X_Co = (self.view.frame.size.width - 290)/2;
    // Setup payment textfield
    self.paymentView = [[PTKView alloc] initWithFrame:CGRectMake(X_Co, 25, 290, 55)];
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
    
    // Setup cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Setup pay button
    NSString *title = [NSString stringWithFormat:@"Pay $%@", self.amount];
    UIBarButtonItem *payButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(pay:)];
    payButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = payButton;
    
    self.lineItems = [NSMutableArray new];
    
}

- (void)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pay:(id)sender
{
    if (![self.paymentView isValid])
    {
        return;
    }
    if (![Stripe defaultPublishableKey])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Publishable Key"
                                                          message:@"Please specify a Stripe Publishable Key i n Constants.m"
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                otherButtonTitles:nil, nil];
        [message show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;

    card.cvc = self.paymentView.card.cvc;
    [Stripe createTokenWithCard:card
                     completion:^(STPToken *token, NSError *error) {
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         if (error) {
                             [self hasError:error];
                         } else {
                             [self hasToken:token];
                         }
                     }];
    

}

- (void)hasError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)hasToken:(STPToken *)token {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // I currently have self.amount which is a NSDecimalNumber.
    // Convert to a string.
    NSString *amount = [self.amount stringValue];

    // Then convert to a float.
    float floatAmount = [amount floatValue];
    
    // Multiply by 100 so the total is represented in cents.
    float total = floatAmount * 100;
    
    // Convert to a string to put into NSDictionary.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithFloat:total]];
    
    // Enumerate through cartArray to get every item.
    Cart *cartObject = [Cart sharedManager];
    for (id object in cartObject.cartArray)
    {
        if ([object isKindOfClass:[ChosenBike class]])
        {
            ChosenBike *bikeObject = (ChosenBike *)object;
            NSDictionary *attributes = @{@"bikeName": bikeObject.chosenName,
                                         @"bikeSize": bikeObject.chosenSize,
                                         @"bikeHasRearBrake": [NSNumber numberWithBool:bikeObject.bicycleHasRearBrake],
                                         @"bicycleWheelsetColor": bikeObject.chosenWheelSetColor,
                                         @"bicycleExtraWheelset": bikeObject.extraSeriesWheelset,
                                         @"bikeQty": bikeObject.chosenQuantity
                                    
                                         };
            NSDictionary *lineItems = @{@"line_item_type": @"bike",
                                        @"line_item_attributes": attributes};
            [self.lineItems addObject:lineItems];
        

        }
        else if ([object isKindOfClass:[ChosenAccessory class]])
        {
            ChosenAccessory *accessoryObject = (ChosenAccessory *)object;
            NSDictionary *attributes = @{@"accessoryName": accessoryObject.chosenName,
                                         @"accessoryQty": accessoryObject.chosenQuantity,
                                         @"accessoryColor": accessoryObject.color,
                                         @"accessorySize": accessoryObject.chosenSize
                                         
                                         };
            NSDictionary *lineItem = @{@"line_item_type": @"accessory",
                                       @"line_item_attributes": attributes};
            [self.lineItems addObject:lineItem];
            
        }
    }
    
    
    // Enumerate through shippingInfo to get every item.
    for (id object in self.shippingInfo)
    {
        self.shippingName = [self.shippingInfo objectAtIndex:0];
        self.email = [self.shippingInfo objectAtIndex:1];
        self.shippingAddress = [self.shippingInfo objectAtIndex:2];
        self.cityState = [self.shippingInfo objectAtIndex:3];
        self.zipcode = [self.shippingInfo objectAtIndex:4];
        
        NSLog(@"%@",object);
        
    }
    
    
    NSDictionary *chargeParams = @{
                                   @"token": token.tokenId,
                                   @"currency": @"usd",
                                   @"amount": result, // this is in cents (i.e. 1000 = $10)
                                   @"lineItems": self.lineItems,
                                   @"name": self.shippingName,
                                   @"email": self.email,
                                   @"address": self.shippingAddress,
                                   @"cityState": self.cityState,
                                   @"zipcode": self.zipcode,
                                   };

    if (!ParseApplicationId || !ParseClientKey) {
        UIAlertView *message =
        [[UIAlertView alloc] initWithTitle:@"Todo: Submit this token to your backend"
                                   message:[NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                            @"instructions in the README to set up Parse as an example backend, or use this "
                                            @"token to manually create charges at dashboard.stripe.com .",
                                            token.tokenId]
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                         otherButtonTitles:nil];
        
        [message show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your account's
    [PFCloud callFunctionInBackground:@"charge"
                       withParameters:chargeParams
                                block:^(id object, NSError *error) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if (error) {
                                        [self hasError:error];
                                        return;
                                    }
                                    else
                                    {
                                        NSString *storyboardName = @"Main";
                                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                                        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"id"];
                                        
                                        [self presentViewController:vc animated:YES completion:^{
                                            [[[UIAlertView alloc] initWithTitle:@"Payment Succeeded!"
                                                                        message:[NSString stringWithFormat:@"An email confirmation was sent to %@", self.email]
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil] show];
                                        }];
                                        [self clearShoppingCart];
                                    }
                        
                                }];
}

- (void) paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"Card number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    NSLog(@"Address zip: %@", card.addressZip);
    
     self.navigationItem.rightBarButtonItem.enabled = valid;
}

- (void)clearShoppingCart
{
    Cart *cart = [Cart sharedManager];
    [cart.cartArray removeAllObjects];
    [cart save];
    
}

@end
