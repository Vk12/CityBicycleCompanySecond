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
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // add extra spaces between Total: and %@
    self.priceLabel.text = [NSString stringWithFormat:@"Total: %*s %@", 5, "", self.subtotal];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.tableView reloadData];
}

- (IBAction)onXDismissedPressed:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITABLEVIEW METHODS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shippingCell"];
    
    Cart *cartItems = [Cart sharedManager];
    id cartShoppingItem = [cartItems.cartArray objectAtIndex:indexPath.row];
    
    if ([cartShoppingItem isKindOfClass:[ChosenBike class]])
    {
        // Make a ChosenBike item object and let Xcode know we're getting back a ChosenBike item.
        ChosenBike *aBike = (ChosenBike *)cartShoppingItem;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ x %@", aBike.chosenName, aBike.chosenQuantity];
        cell.detailTextLabel.text = [aBike.chosenPrice stringValue];
    }
    else if ([cartShoppingItem isKindOfClass:[ChosenAccessory class]])
    {
        // Make a ChosenAccessory item object and let Xcode know we're getting back a ChosenAccessoryItem.
        ChosenAccessory *anAccessory = (ChosenAccessory *)cartShoppingItem;
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@", anAccessory.chosenName, anAccessory.chosenQuantity];
        
        // Convert chosenPrice into a CGFloat
        CGFloat totalPrice = [anAccessory.chosenPrice floatValue];
        // So that can change formatting/decimal place if the price is a whole number (ex: 120 vs. 120.00).
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%3.2f", totalPrice];
        
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Cart *shoppingCartArray = [Cart sharedManager];
    return shoppingCartArray.cartArray.count;
}

@end
