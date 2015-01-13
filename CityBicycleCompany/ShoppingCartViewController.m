
//  ShoppingCartViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

// View Controllers
#import "ShoppingCartViewController.h"
#import "ShippingViewController.h"
#import "AccessoriesViewController.h"

// Model Classes
#import "Photo.h"
#import "Bicycle.h"
#import "ChosenBike.h"
#import "ChosenAccessory.h"
#import "Cart.h"

// Frameworks
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import "Stripe+ApplePay.h"
#import "Stripe.h"

// Custom Cells
#import "ShoppingCartTableViewCell.h"
#import "PaymentViewController.h"

#import "Constants.h"

#define kOFFSET_FOR_KEYBOARD 80.0


@interface ShoppingCartViewController () <PKPaymentAuthorizationViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,ShoppingCartCellDelegate, UITextFieldDelegate>

// PROPERTIES:

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Shopping cart array properties
@property NSMutableArray *shoppingCartArray;
@property Cart *singleton;

// Shopping cart totals
@property NSString *priceSummary;
@property NSString *itemLineSummary;
@property (strong, nonatomic) IBOutlet UILabel *subTotalLabel;
@property NSString *subtotalSummary;

// Keyboard
@property BOOL isKeyBoardShowing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomOfTableView;
@property CGFloat initialBottomOfTableView;

// Server backend
@property NSMutableArray *lineItems;
@property NSString *shippingName;
@property NSDictionary *addressDict;
@property NSString *email;

@end

@implementation ShoppingCartViewController

// Method for presenting this VC when shopping cart icon is tapped
+ (ShoppingCartViewController *)newFromStoryboard;
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return  [storyboard instantiateViewControllerWithIdentifier:@"ShoppingCartViewController"];
    
}

#pragma VIEW CONTROLLER LIFE CYCLES
- (void)viewDidLoad
{
    // Instantiate stuff
    Cart *singleton = [Cart sharedManager];
    self.singleton = singleton;
    self.shoppingCartArray = self.singleton.cartArray;
    
    self.lineItems = [NSMutableArray new];
    
    [self keyboardNotifications];
    [self.singleton load];
    [self.tableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
   
    [self.singleton load];
    
    self.initialBottomOfTableView = self.bottomOfTableView.constant;

    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self refreshTotal];
}

#pragma mark - KEYBOARD HIDE
// Keyboard is set to not block qty text field in editing mode.

- (void)keyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
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
    self.subTotalLabel.text = [NSString stringWithFormat:@"%3.2f", cartTotal];
}

-(void)updatedQty:(NSNumber *)qty fromCell:(ShoppingCartTableViewCell *)cell
{
    NSIndexPath *p = [self.tableView indexPathForCell:cell];
    id item = self.shoppingCartArray[p.row];
    [item setChosenQuantity:qty];
    
    // When quantity is updated, update chosenPrice.
    // Then save so the total will be there if the app is closed.
    
    [self refreshTotal];
    [self.singleton save];
    
}

#pragma mark - UITABLEVIEW DELEGATE METHODS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShoppingCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bicycleCell"];
    
    // Had to set up custom delegation because of our text field within the custom cell.
    cell.delegate = self;
    
    // Take each item in our shopping cart array and figure out what kind of item it is.
    id cartItem = [self.singleton.cartArray objectAtIndex:indexPath.row];

    if ([cartItem isKindOfClass:[ChosenBike class]])
    {
        // We know for sure we're getting our object from our cartItem array.
        ChosenBike *bike = (ChosenBike *)cartItem;
        
        cell.productNameLabel.text = bike.chosenName;
        
        if ([bike.chosenWheelSetColor isEqualToString:@"Black"])
        {
            cell.colorLabel.text = @"Black wheelset";
        }
        else
        {
            cell.colorLabel.text = [NSString stringWithFormat:@"%@ wheelset: 15.00", bike.chosenWheelSetColor];

        }

        cell.sizeLabel.text = bike.chosenSize;

        if (bike.bicycleHasRearBrake == YES)
        {
            cell.rearBrakeLabel.text = @"Rear brake: 30.00";
        }
        else
        {
            [cell.rearBrakeLabel setHidden:YES];
        }
        
        if ([bike.extraSeriesWheelset  isEqual: @"None"])
        {
            [cell.extraWheelsetLabel setHidden:YES];
        }
        else
        {
            cell.extraWheelsetLabel.text = @"Extra wheelset: 80.00";
            // Took below out because constraints looked weird (lines too long on one line).
            // Leaving this in as a comment in case it makes sense to put back later.
            // (originally it also listed the color of the chosen extra wheel set)
//            [NSString stringWithFormat:@"Extra wheelset: 80.00", testBike.extraSeriesWheelset];

        }
        
        cell.qtyTextField.text = [bike.chosenQuantity stringValue];
        
        CGFloat totalPrice = [bike.chosenPrice floatValue] * [bike.chosenQuantity floatValue];
        
        cell.priceLabel.text = [NSString stringWithFormat:@"%3.2f",totalPrice];
        
        // Text field won't be enabled until editing mode is on.
        // so it doesn't look like a text field initially.
        cell.qtyTextField.enabled = NO;
        [cell.qtyTextField setBorderStyle:UITextBorderStyleNone];

    }
    
    else if ([cartItem isKindOfClass:[ChosenAccessory class]]){
        
        // We know for sure we're getting this object from our cartItem array.
        ChosenAccessory *accessory = (ChosenAccessory *)cartItem;

        cell.productNameLabel.text = accessory.chosenName;
        cell.priceLabel.text = accessory.salePrice;
        cell.qtyTextField.text = [accessory.chosenQuantity stringValue];
        cell.colorLabel.text = accessory.color;
        cell.sizeLabel.text = accessory.chosenSize;
        CGFloat totalPrice = [accessory.chosenPrice floatValue] * [accessory.chosenQuantity floatValue];
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.shoppingCartArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // When we delete a row from tableview, we update the price total, our shopping cart count, and save this to our singleton array.
        [self refreshTotal];
        [self.singleton save];
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
    
    
    [self.singleton save];
    

}

- (IBAction)onDismissButtonTapped:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCreditCartButtonTapped:(UIButton *)sender
{
    NSLog(@"Credit card button tapped");

    // When button is tapped, segues to ShippingViewController via Storyboard.
    // Only segues if there's something in the cart.  If there isn't, present UIAlert.
    
    if (self.singleton.cartArray.count == 0)
    {
        NSLog(@"Nothing in there");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your cart is empty"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }
    
}

- (IBAction)onApplePayButtonTapped:(UIButton *)sender
{
    NSLog(@"button was tapped");
    
    // Apple Pay checkout process begins only if there's something in the cart.
    // If there's not, present UIAlertView.
    
    if (self.singleton.cartArray.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your cart is empty"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    else
    {
        [self checkApplePay];
    }
}

#pragma mark Apple Pay enabled check

// Check to see if user has Apple Pay
- (void)checkApplePay
{
    // Prepare our data to send to Apple Pay.
    [self getCartData];
    
    // Generating a PKPaymentRequest to submit to Apple.
    PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:@"merchant.MayVA.CityBicycleCompanyApp"];
    
    // Our user is forced to input all of these fields.
    [request setRequiredShippingAddressFields:PKAddressFieldAll];
    
    
    // Set the paymentSummaryItems to a NSArray of PKPaymentSummaryItems.  "These are analogous to line items on a receipt."
    NSString *label = @"City Bicycle Co.";
    NSString *paymentSummary = self.subTotalLabel.text;
    
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:paymentSummary];
    
    request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:label amount:number]];
    
    // Query to check if ApplePay is available for the phone user.
    if ([Stripe canSubmitPaymentRequest:request])
    {
        // Create and display the payment request view controller.
        // In debug mode, we're just going to use Apple Pay payment sheet instead of Stripe's test controller.
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

    // We're taking the user's address and contact details and putting it into shippingObjects.
    id shippingObjects = [payment shippingAddress];
    
    // Just a test to check if we were able to fetch the shipping object.
    NSLog(@"%@", ABRecordCopyCompositeName((__bridge ABRecordRef)(shippingObjects)));
    
    // Get shipping name.
    self.shippingName = (__bridge NSString *)(ABRecordCopyCompositeName((__bridge ABRecordRef)(shippingObjects)));
    
    
    // Get shipping address details.
    // Let's put it all into one dictionary and then we can call specific keys when we need to.
    CFTypeRef addressProperty = ABRecordCopyValue((__bridge ABRecordRef)shippingObjects, kABPersonAddressProperty);
    self.addressDict = (__bridge NSDictionary *)CFArrayGetValueAtIndex((CFArrayRef)ABMultiValueCopyArrayOfAllValues(addressProperty), 0);
    
    // Get email.
    CFTypeRef email = ABRecordCopyValue((__bridge ABRecordRef)(shippingObjects), kABPersonEmailProperty);
    self.email =(__bridge NSString *)CFArrayGetValueAtIndex((CFArrayRef)ABMultiValueCopyArrayOfAllValues(email), 0);

}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // The method below changes the view to the ProductViewController when this delegate is called.
    // This is an awkward place to put it, but the shopping count counter behaves strangely if put anywhere else.
    // If user cancels payment sheet without paying, cancel button triggers this method, which is OK I guess.
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"id"];
    
    [self presentViewController:vc animated:YES completion:nil];
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
    // Error message in case there's something wrong with my Parse keys.
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
    // Send the charge amount to Stripe.  But first, put the amount in proper format.
    
    // First, convert subtotal (NSString) to float.
    float total = [self.subTotalLabel.text floatValue];
    
    // Multiply the float value by 100 so that the total is represented in cents.
    float total2 = total * 100;
    
    // Use NSNumberFormatter to get rid of the trailing zeroes that occur when converting a float to a string.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:total2];
    [formatter setMinimumFractionDigits:0];
    
    // Convert to a string to put into NSDictionary.  Amount done.
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithFloat:total2]];
    
    // Now append City and State keys to one NSString.
    NSString *city = [NSString stringWithFormat:@"%@, ", self.addressDict[@"City"]];
    NSString *state = self.addressDict[@"State"];
    NSString *cityState = [city stringByAppendingString:state];
    
    
    NSDictionary *chargeParams = @{
                                   @"token": token.tokenId,
                                   @"currency": @"usd",
                                   @"amount": result, // this is in cents (i.e. 1000 cents = $10)
                                   @"lineItems": self.lineItems,
                                   @"name": self.shippingName,
                                   @"email": self.email,
                                   @"address": self.addressDict[@"Street"],
                                   @"cityState": cityState,
                                   @"zipcode": self.addressDict[@"ZIP"]
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
                                        
                                        [[[UIAlertView alloc] initWithTitle:@"Payment Succeeded!"
                                                                   message:[NSString stringWithFormat:@"An email confirmation was sent to %@", self.email]
                                                                  delegate:nil
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:@"OK", nil] show];
                                        
                                        [self.singleton.cartArray removeAllObjects];
                                        [self.singleton save];
                                        
                                    }
                                }];
    
    
    }

- (void)getCartData
{
    NSLog(@"Test");
    // Enumerate through cartArray to get every item.
    for (id object in self.singleton.cartArray)
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // Segue to ShippingViewController won't work if there's nothing in the shopping cart.
    if (self.singleton.cartArray.count == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}



@end
