
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
#import <AddressBook/AddressBook.h>
#define kOFFSET_FOR_KEYBOARD 80.0

#if DEBUG
#import "STPTestPaymentAuthorizationViewController.h"
#import "PKPayment+STPTestKeys.h"
#endif


@interface ShoppingCartViewController () <PKPaymentAuthorizationViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,ShoppingCartCellDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *shoppingCartArray;
@property NSString *priceSummary;
@property NSString *itemLineSummary;
@property (strong, nonatomic) IBOutlet UILabel *subTotalLabel;
@property NSString *subtotalSummary;
@property BOOL isKeyBoardShowing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomOfTableView;
@property CGFloat initialBottomOfTableView;
@property NSMutableArray *lineItems;
@property NSString *shippingName;
@property NSDictionary *addressDict;
@property NSString *email;
@property Cart *singleton;

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
    
    self.lineItems = [NSMutableArray new];
    
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
            cell.extraWheelsetLabel.text = @"Extra wheelset: 80.00";
            // Took below out because constraints looked weird (lines too long on one line).
//            [NSString stringWithFormat:@"Extra wheelset: 80.00", testBike.extraSeriesWheelset];

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

    // When button is tapped, segues to ShippingViewController via Storyboard.
    
    Cart *cart = [Cart sharedManager];
    if (cart.cartArray.count == 0)
    {
        NSLog(@"Nothing in there");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your cart is empty"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Continue Shopping"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }
    else
    {
        
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    Cart *cart = [Cart sharedManager];
    if (cart.cartArray.count == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (IBAction)onPayButtonTapped:(UIButton *)sender
{
    NSLog(@"button was tapped");
    
    [self getCartData];
    
    // Generating a PKPaymentRequest to submit to Apple.
    PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:@"merchant.MayVA.CityBicycleCompanyApp"];
    [request setRequiredShippingAddressFields:PKAddressFieldAll];
    
    
    // Set the paymentSummaryItems to a NSArray of PKPaymentSummaryItems.  These are analogous to line items on a receipt.
    NSString *label = @"City Bicycle Co.";
    NSString *paymentSummary = self.subTotalLabel.text;
    
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:paymentSummary];
    
    request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:label amount:number]];
    
    // Query to check if ApplePay is available for the phone user.
    if ([Stripe canSubmitPaymentRequest:request])
    {
        // request.shippingAddress
        // Create and display the payment request view controller.
#if DEBUG
        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        
#else
        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        NSString *address = request.shippingAddress;

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

    id shippingObjects = [payment shippingAddress];
    
    // Just a test to check if we were able to fetch the shipping object.
    NSLog(@"%@", ABRecordCopyCompositeName((__bridge ABRecordRef)(shippingObjects)));
    
    // Get shipping name.
    self.shippingName = (__bridge NSString *)(ABRecordCopyCompositeName((__bridge ABRecordRef)(shippingObjects)));
    
    
    // Get shipping address details.
    CFTypeRef addressProperty = ABRecordCopyValue((__bridge ABRecordRef)shippingObjects, kABPersonAddressProperty);
    self.addressDict = (__bridge NSDictionary *)CFArrayGetValueAtIndex((CFArrayRef)ABMultiValueCopyArrayOfAllValues(addressProperty), 0);
    
    // Get email.
    CFTypeRef email = ABRecordCopyValue((__bridge ABRecordRef)(shippingObjects), kABPersonEmailProperty);
    self.email =(__bridge NSString *)CFArrayGetValueAtIndex((CFArrayRef)ABMultiValueCopyArrayOfAllValues(email), 0);

}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        [[[UIAlertView alloc] initWithTitle:@"Payment Succeeded!"
                                   message:[NSString stringWithFormat:@"An email confirmation was sent to %@", self.email]
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil] show];
    }];
    
    Cart *cart = [Cart sharedManager];
    [cart.cartArray removeAllObjects];
    [cart save];
    
    
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
    
    // Append City and State keys to one NSString.
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
                                        
//                                        NSString *storyboardName = @"Main";
//                                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
//                                        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"id"];
//                                        
//                                        [self presentViewController:vc animated:YES completion:nil];
                                        
                                    }
                                }];
    
    
    }

- (void)getCartData
{
    NSLog(@"Test");
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
