//
//  ShoppingCartTableViewCell.h
//  CityBicycleCompany
//
//  Created by May Yang on 12/4/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingCartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UITextField *qtyTextField;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *rearBrakeLabel;
@property (weak, nonatomic) IBOutlet UILabel *extraWheelsetLabel;
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;

@end
