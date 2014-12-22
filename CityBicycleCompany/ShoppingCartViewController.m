
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
#import "ShippingViewController.h"
#import "Photo.h"
#import "Bicycle.h"
#import "ChosenBike.h"
#import "ShoppingCartTableViewCell.h"
#import "AccessoriesViewController.h"
#import "ChosenAccessory.h"
#import "Cart.h"
#import "PaymentViewController.h"
#define kOFFSET_FOR_KEYBOARD 80.0

#if DEBUG
#import "STPTestPaymentAuthorizationViewController.h"
#import "PKPayment+STPTestKeys.h"
#endif


@interface ShoppingCartViewController () <PKPaymentAuthorizationViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,ShoppingCartCellDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *buyWithIpayButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *shoppingCartArray;
@property NSString *priceSummary;
@property NSString *itemLineSummary;
@property (strong, nonatomic) IBOutlet UILabel *subTotalLabel;
@property NSString *subtotalSummary;
@property BOOL isKeyBoardShowing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomOfTableView;
@property CGFloat initialBottomOfTableView;

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
    
    Cart *test = [Cart sharedManager];
    self.shoppingCartArray = test.cartArray;
    [test load];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
        
    [self.tableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    Cart *loadCart = [Cart sharedManager];
    [loadCart load];
    
    self.initialBottomOfTableView = self.bottomOfTableView.constant;

    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    [self refreshTotal];
}

#pragma mark - KEYBOARD HIDE
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (self.isKeyBoardShowing)
    return;
    
    NSDictionary *userInfo = [notification userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    
    self.bottomOfTableView.constant = keyboardSize.height;
    
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    self.bottomOfTableView.constant = self.initialBottomOfTableView;
}


#pragma mark - HELPER METHODS FOR SHOPPING CART TABLEVIEW
-(void)refreshTotal
{
    CGFloat cartTotal = 0.0;
    for (id item in self.shoppingCartArray)
    {
        CGFloat totalItemPrice = [[item chosenQuantity] floatValue] * [[item chosenPrice] floatValue];
        cartTotal = cartTotal + totalItemPrice;
    }
    self.priceSummary =
    self.subTotalLabel.text = [NSString stringWithFormat:@"%3.2f", cartTotal];
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
        
        if ([testBike.chosenWheelSetColor isEqualToString:@"Black"])
        {
            cell.colorLabel.text = @"Black wheelset";
        }
        else
        {
            cell.colorLabel.text = [NSString stringWithFormat:@"%@ wheelset: 15.00", testBike.chosenWheelSetColor];

        }

        cell.sizeLabel.text = testBike.chosenSize;

        if (testBike.bicycleHasRearBrake == YES)
        {
            cell.rearBrakeLabel.text = @"Rear brake: 30.00";
        }
        else
        {
            [cell.rearBrakeLabel setHidden:YES];
        }
        
        if ([testBike.extraSeriesWheelset  isEqual: @"None"])
        {
            [cell.extraWheelsetLabel setHidden:YES];
        }
        else
        {
            cell.extraWheelsetLabel.text = [NSString stringWithFormat:@"Extra %@ wheelset: 80.00", testBike.extraSeriesWheelset];

        }
        
        cell.qtyTextField.text = [testBike.chosenQuantity stringValue];
        
        CGFloat totalPrice = [testBike.chosenPrice floatValue] * [testBike.chosenQuantity floatValue];
        
        cell.priceLabel.text = [NSString stringWithFormat:@"%3.2f",totalPrice];
        
        cell.qtyTextField.enabled = NO;
        [cell.qtyTextField setBorderStyle:UITextBorderStyleNone];
        
        

    } else if ([testShoppingItem isKindOfClass:[ChosenAccessory class]]){
        
        ChosenAccessory *testAccessory = (ChosenAccessory *)testShoppingItem;

        cell.productNameLabel.text = testAccessory.chosenName;
        cell.priceLabel.text = testAccessory.salePrice;
        cell.qtyTextField.text = [testAccessory.chosenQuantity stringValue];
        cell.colorLabel.text = testAccessory.color;
        cell.sizeLabel.text = testAccessory.chosenSize;
        CGFloat totalPrice = [testAccessory.chosenPrice floatValue] * [testAccessory.chosenQuantity floatValue];
        cell.priceLabel.text = [NSString stringWithFormat:@"%3.2f",totalPrice];
        self.itemLineSummary = cell.productNameLabel.text;
    
        
        [cell.rearBrakeLabel setHidden:YES];
        [cell.extraWheelsetLabel setHidden:YES];
    }

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

- (IBAction)onCreditCartButtonTapped:(UIButton *)sender
{
    NSLog(@"Credit card button tapped");


//    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
//
//    // Convert subtotal (string) to NSDecimalNumber and pass it to paymentViewController.
//    paymentViewController.amount = [NSDecimalNumber decimalNumberWithString:self.subTotalLabel.text];
//
//    
//    [self presentViewController:navController animated:YES completion:nil];
    
}

- (IBAction)onPayButtonTapped:(UIButton *)sender
{
    NSLog(@"button was tapped");
    
    // Generating a PKPaymentRequest to submit to Apple.
    PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:@"merchant.MayVA.CityBicycleCompanyApp"];
    [request setRequiredShippingAddressFields:PKAddressFieldPostalAddress];
    [request setRequiredBillingAddressFields:PKAddressFieldPostalAddress];
    
    
    // Set the paymentSummaryItems to a NSArray of PKPaymentSummaryItems.  These are analogous to line items on a receipt.
    NSString *label = @"City Bicycle Co.";
    NSString *paymentSummary = self.subTotalLabel.text;
    
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:paymentSummary];
    
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
        // Put an alert view that tells the user to register for Apple Pay.
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Apple Pay not found"
                                                        message:@"Please register for Apple Pay on this device."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
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
    // First, convert subtotal (NSString) to float.
    float total = [self.subTotalLabel.text floatValue];
    
    // Multiply the float value by 100 so that the total is represented in cents.
    float total2 = total * 100;
    
    // Use NSNumberFormatter to get rid of the trailing zeroes that occur when converting a float to a string.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:total2];
    [formatter setMinimumFractionDigits:0];
    
    // Convert to a string to put into NSDictionary.
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithFloat:total2]];
    
    
    NSDictionary *chargeParams = @{
                                   @"token": token.tokenId,
                                   @"currency": @"usd",
                                   @"amount": result // this is in cents (i.e. 1000 cents = $10)
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
    
    
    }

#pragma mark - SEGUE
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"shippingSegue"])
    {
        ShippingViewController *vc = segue.destinationViewController;
        vc.subtotal = self.subTotalLabel.text;
        
    }
}




@end
