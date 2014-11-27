//
//  ShoppingCartViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "Stripe+ApplePay.h"
#import "Stripe.h"
@interface ShoppingCartViewController ()
@property (strong, nonatomic) IBOutlet UIButton *buyWithIpayButton;

@end

@implementation ShoppingCartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (IBAction)onPayButtonTapped:(UIButton *)sender
{
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:YOUR_APPLE_MERCHANT_ID];
    // Configure your request here.
    NSString *label = @"Premium Llama Food";
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];
    request.paymentSummaryItems = @[
                                    [PKPaymentSummaryItem summaryItemWithLabel:label
                                                                        amount:amount];
                                    ];
    
    if ([Stripe canSubmitPaymentRequest:request]) {
        ...
    } else {
        // Show the user your own credit card form (see options 2 or 3)
    }

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
