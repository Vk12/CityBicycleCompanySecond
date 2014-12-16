//
//  PaymentViewController.m
//  CityBicycleCompany
//
//  Created by May Yang on 12/15/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "PaymentViewController.h"


@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.paymentView = [[PTKView alloc] initWithFrame:CGRectMake(15, 25, 290, 55)];
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
}

- (void) paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"Card number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    NSLog(@"Address zip: %@", card.addressZip);
    
     self.navigationItem.rightBarButtonItem.enabled = valid;
}

@end
