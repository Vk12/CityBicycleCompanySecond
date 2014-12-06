
//  ShoppingCartViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <Parse/Parse.h>
#import "ShoppingCartViewController.h"
#import "Stripe+ApplePay.h"
#import "Stripe.h"
#import "Constants.h"
#import "ShippingManagerViewController.h"
#import "Photo.h"
#import "Bicycle.h"
#import "ChosenBike.h"
#import "ShoppingCartTableViewCell.h"
#import "AccessoriesViewController.h"
#import "ChosenAccessory.h"

#if DEBUG
#import "STPTestPaymentAuthorizationViewController.h"
#import "PKPayment+STPTestKeys.h"
#endif


@interface ShoppingCartViewController () <PKPaymentAuthorizationViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *buyWithIpayButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *shoppingCartArray;
@property NSString *priceSummary;
@property NSString *itemLineSummary;

@end

@implementation ShoppingCartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    ChosenBike *testBike = self.theChosenBike.passTheBikeArray[0];
//    NSLog(@"slkfl;aslf;saljdfklasdkl;fsa;lf;lsaldkfklaslfksa;lfalsdflsadk %@",testBike.chosenName);
//    
//    ChosenAccessory *testAccessory = self.theChosenAccessory.passTheAccessoryArray[0];
//    NSLog(@"test %@", testAccessory.chosenQuantity);
    
    self.shoppingCartArray = [@[]mutableCopy];
    self.shoppingCartArray = [NSMutableArray arrayWithArray:self.theChosenBike.passTheBikeArray];
    [self.shoppingCartArray addObjectsFromArray:self.theChosenAccessory.passTheAccessoryArray];

//    // Testing Cloud Code
//    [PFCloud callFunctionInBackground:@"stripe"
//                       withParameters:@{}
//                                block:^(NSString *result, NSError *error) {
//                                    if (!error) {
//                                        // result is hello world
//                                        
//                                    }
//                                    }];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    self.shoppingCartArray = [@[]mutableCopy];
//    self.shoppingCartArray = [NSMutableArray arrayWithArray:self.theChosenBike.passTheBikeArray];
//    [self.shoppingCartArray addObjectsFromArray:self.theChosenAccessory.passTheAccessoryArray];
    
    ShoppingCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bicycleCell"];
    id shoppingCartItem = [self.shoppingCartArray objectAtIndex:indexPath.row];
    
    if ([shoppingCartItem isKindOfClass:[ChosenBike class]])
    {
        ChosenBike *testBike = (ChosenBike *)shoppingCartItem;
        
        cell.productNameLabel.text = testBike.chosenName;
        cell.colorLabel.text = testBike.chosenWheelSetColor;
        cell.sizeLabel.text = testBike.chosenSize;
        //TODO: not sure how to show rear brake because it's a bool
        cell.extraWheelsetLabel.text = testBike.extraSeriesWheelset;
        cell.qtyTextField.text = [testBike.chosenQuantity stringValue];
        cell.priceLabel.text = [testBike.chosenPrice stringValue];
        self.priceSummary = cell.priceLabel.text;
        self.itemLineSummary = cell.productNameLabel.text;

    } else if ([shoppingCartItem isKindOfClass:[ChosenAccessory class]]){
        
        ChosenAccessory *testAccessory = (ChosenAccessory *)shoppingCartItem;

        cell.productNameLabel.text = testAccessory.chosenName;
        cell.priceLabel.text = testAccessory.salePrice;
        cell.qtyTextField.text = [testAccessory.chosenQuantity stringValue];
        cell.colorLabel.text = testAccessory.color;
        cell.sizeLabel.text = testAccessory.chosenSize;
        cell.priceLabel.text = [testAccessory.chosenPrice stringValue];
        self.priceSummary = cell.priceLabel.text;
        self.itemLineSummary = cell.productNameLabel.text;

        [cell.rearBrakeLabel setHidden:YES];
        [cell.extraWheelsetLabel setHidden:YES];
    }
    
//    ChosenAccessory *testAccessory = self.theChosenAccessory.passTheAccessoryArray[0];
//    ChosenBike *testBike = self.theChosenBike.passTheBikeArray[0];
//    ShoppingCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bicycleCell"];
    return cell;
    

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shoppingCartArray.count;
    
}

- (IBAction)removeButton:(UIButton *)sender {
}


//- (NSArray *)summaryItemsForShippingMethod
//{
//    NSDecimalNumber *number = self.priceSummary;
//
//    PKPaymentSummaryItem *foodItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Premium Llama food" amount:number];
//    NSDecimalNumber *total = [foodItem.amount decimalNumberByAdding:number];
//    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Llama Food Services, Inc." amount:total];
//    return @[foodItem, totalItem];
//}

- (IBAction)onDismissButtonTapped:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPayButtonTapped:(UIButton *)sender
{
    NSLog(@"button was tapped");
    
    // Generating a PKPaymentRequest to submit to Apple.
    PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:@"merchant.MayVA.CityBicycleCompanyApp"];
    [request setRequiredShippingAddressFields:PKAddressFieldPostalAddress];
    [request setRequiredBillingAddressFields:PKAddressFieldPostalAddress];

    
//TODO: CONFIGURE REQUEST.
    
    // Set the paymentSummaryItems to a NSArray of PKPaymentSummaryItems.  These are analogous to line items on a receipt.
    NSString *label = @"City Bicycle Co.";
    NSString *paymentSummary = self.priceSummary;

    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:paymentSummary];
//    request.paymentSummaryItems = @[[self summaryItemsForShippingMethod]];
    request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:label amount:number]];
    
    // Query to check if ApplePay is available for the phone user.
    if ([Stripe canSubmitPaymentRequest:request])
    {
    // Create and display the payment request view controller.
#if DEBUG
        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
#else
        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
#endif
        auth.delegate = self;
        [self presentViewController:auth animated:YES completion:nil];
    }
    else
    {
        // Show the user your own credit card form (Stripe PaymentKit or credit card form)
        
//        PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
        
    }
    
    
}

#pragma mark PKPaymentAuthorizationViewControllerDelegate Protocols

// This protocol returns a PKPayment, that we pass into the method within.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark PKPaymentAuthorizationViewControllerDelegate Helper Methods

// This method creates a single-use token.
- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    [Stripe createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
            return;
        }
        
        [self createBackendChargeWithToken:token completion:completion];
    }];
}

// This method sends the token to server
- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    if (!ParseApplicationId || !ParseClientKey)
    {
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
        completion(PKPaymentAuthorizationStatusSuccess);
        return;
    }
    NSDictionary *chargeParams = @{
                                   @"token": token.tokenId,
                                   @"currency": @"usd",
                                   @"amount": @"1000", // this is in cents (i.e. $10)
                                   };
    // This passes the token off to our payment backend, which will then actually complete charging the card using your account's
    [PFCloud callFunctionInBackground:@"charge"
                       withParameters:chargeParams
                                block:^(id object, NSError *error) {
                                    if (error) {
                                        completion(PKPaymentAuthorizationStatusFailure);
                                    } else {
                                        // We're done!
                                        completion(PKPaymentAuthorizationStatusSuccess);
                                        [[[UIAlertView alloc] initWithTitle:@"Payment Succeeded"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil] show];
                                    }
                                }];
    
    
//    NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"POST";
//    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
//    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response,
//                                               NSData *data,
//                                               NSError *error) {
//                               if (error) {
//                                   completion(PKPaymentAuthorizationStatusFailure);
//                               } else {
//                                   completion(PKPaymentAuthorizationStatusSuccess);
//                               }
//                           }];
}


@end
