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

@interface ShippingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property UIGestureRecognizer *tapper;

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

- (IBAction)onXDismissedPressed:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
