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
    
    
}

- (void)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pay:(id)sender
{
    
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
