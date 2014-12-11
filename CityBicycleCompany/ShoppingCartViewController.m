
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
#import "Cart.h"

#if DEBUG
#import "STPTestPaymentAuthorizationViewController.h"
#import "PKPayment+STPTestKeys.h"
#endif


@interface ShoppingCartViewController () <PKPaymentAuthorizationViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,ShoppingCartCellDelegate>
@property (strong, nonatomic) IBOutlet UIButton *buyWithIpayButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *shoppingCartArray;
@property NSString *priceSummary;
@property NSString *itemLineSummary;
@property (strong, nonatomic) IBOutlet UILabel *subTotalLabel;
@property NSString *subtotalSummary;

@property NSString *chosenBikePriceSubtotal;
@property NSMutableArray *combinedPrices;
@property NSString *accessoryPriceSubtotal;

@end

@implementation ShoppingCartViewController

+ (ShoppingCartViewController *)newFromStoryboard;
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return  [storyboard instantiateViewControllerWithIdentifier:@"ShoppingCartViewController"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.combinedPrices = [NSMutableArray new];
    

#if TARGET_IPHONE_SIMULATOR
    // where are you?
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif
    
//    Cart *loadCart = [Cart sharedManager];
//    [loadCart load];
    
    Cart *test = [Cart sharedManager];
    self.shoppingCartArray = test.cartArray;
    [test load];
    

    
    [self.tableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    Cart *loadCart = [Cart sharedManager];
    [loadCart load];
    


    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self refreshTotal];
//    Cart *loadCart = [Cart sharedManager];
//    [loadCart load];
}

-(void)refreshTotal
{
    CGFloat cartTotal = 0.0;
    for (id item in self.shoppingCartArray)
    {
        CGFloat totalItemPrice = [[item chosenQuantity] floatValue] * [[item chosenPrice] floatValue];
        cartTotal = cartTotal + totalItemPrice;
    }
    self.subTotalLabel.text = [NSString stringWithFormat:@"$%3.2f", cartTotal];
}

-(void)updatedQty:(NSNumber *)qty fromCell:(ShoppingCartTableViewCell *)cell
{
    NSIndexPath *p = [self.tableView indexPathForCell:cell];
    id item = self.shoppingCartArray[p.row];
    [item setChosenQuantity:qty];
    
    // When quantity is updated, update chosenPrice.
    
 
    [self refreshTotal];
    
    Cart *cart = [Cart sharedManager];
    [cart save];
    
}

#pragma mark - UITABLEVIEW DELEGATE METHODS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    ShoppingCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bicycleCell"];

    cell.delegate = self;
    
    Cart *test = [Cart sharedManager];
    id testShoppingItem = [test.cartArray objectAtIndex:indexPath.row];


        if ([testShoppingItem isKindOfClass:[ChosenBike class]])
    {
        ChosenBike *testBike = (ChosenBike *)testShoppingItem;
        
        cell.productNameLabel.text = testBike.chosenName;
//        cell.colorLabel.text = [testBike.chosenQuantity stringValue];
        cell.colorLabel.text = testBike.chosenWheelSetColor;
        cell.sizeLabel.text = testBike.chosenSize;
        //TODO: not sure how to show rear brake because it's a bool
        cell.extraWheelsetLabel.text = testBike.extraSeriesWheelset;
        cell.qtyTextField.text = [testBike.chosenQuantity stringValue];
        
        CGFloat totalPrice = [testBike.chosenPrice floatValue] * [testBike.chosenQuantity floatValue];
        
        cell.priceLabel.text = [NSString stringWithFormat:@"$%3.2f",totalPrice];
        self.priceSummary = cell.priceLabel.text;
        
        self.itemLineSummary = cell.productNameLabel.text;
        cell.qtyTextField.enabled = NO;
        [cell.qtyTextField setBorderStyle:UITextBorderStyleNone];

        self.chosenBikePriceSubtotal = cell.priceLabel.text;
        [self.combinedPrices addObject:self.chosenBikePriceSubtotal];
        

    } else if ([testShoppingItem isKindOfClass:[ChosenAccessory class]]){
        
        ChosenAccessory *testAccessory = (ChosenAccessory *)testShoppingItem;

        cell.productNameLabel.text = testAccessory.chosenName;
        cell.priceLabel.text = testAccessory.salePrice;
        cell.qtyTextField.text = [testAccessory.chosenQuantity stringValue];
        cell.colorLabel.text = testAccessory.color;
        cell.sizeLabel.text = testAccessory.chosenSize;
        CGFloat totalPrice = [testAccessory.chosenPrice floatValue] * [testAccessory.chosenQuantity floatValue];
        cell.priceLabel.text = [NSString stringWithFormat:@"$%3.2f",totalPrice];
        self.priceSummary = cell.priceLabel.text;
        self.itemLineSummary = cell.productNameLabel.text;
        
        self.accessoryPriceSubtotal = cell.priceLabel.text;
        
        [self.combinedPrices addObject:self.accessoryPriceSubtotal];
        
        [cell.rearBrakeLabel setHidden:YES];
        [cell.extraWheelsetLabel setHidden:YES];
    }
    
//    else if ([self.combinedPrices containsObject:self.chosenBikePriceSubtotal] && [self.combinedPrices containsObject:self.accessoryPriceSubtotal])
//    {
//
//        NSString *stringValue = self.chosenBikePriceSubtotal;
//        float value = [stringValue floatValue];
//        
//        NSString *stringValue2 = self.accessoryPriceSubtotal;
//        float value2 = [stringValue2 floatValue];
//        
//        float value3 = value + value2;
//        
//        NSString *stringValue3 = [NSString stringWithFormat:@"Subtotal: $%f", value3];
//        
//        self.subTotalLabel.text = stringValue3;
//        
//        
//    }
//    

    if (self.tableView.isEditing)
    {
        [cell.qtyTextField setBorderStyle:UITextBorderStyleRoundedRect];
        cell.qtyTextField.enabled = YES;
    }
    else
    {
        [cell.qtyTextField setBorderStyle:UITextBorderStyleNone];
        cell.qtyTextField.enabled = NO;
    }
    
    return cell;
    
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shoppingCartArray.count;
    
}


#pragma mark - UITABLEVIEW EDITING MODE DELEGATE METHODS

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.shoppingCartArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self refreshTotal];
        Cart *cart = [Cart sharedManager];
        [cart save];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cartChanged" object:nil];

    }
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    self.tableView.editing = YES;
    [self.tableView reloadData];
    NSLog(@"setEditing is on");
    
}


#pragma mark - UIBUTTON METHODS

- (IBAction)onEditButtonTapped:(UIButton *)sender
{
    self.tableView.editing = !self.tableView.isEditing;
    [self.tableView reloadData];
    
    if ([self.tableView isEditing])
    {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    
    }
    else
    {

        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
    
    
    Cart *cart = [Cart sharedManager];
    [cart save];
    

}

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
