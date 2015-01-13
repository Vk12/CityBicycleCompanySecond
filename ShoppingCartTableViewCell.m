//
//  ShoppingCartTableViewCell.m
//  CityBicycleCompany
//
//  Created by May Yang on 12/4/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "ShoppingCartTableViewCell.h"


@implementation ShoppingCartTableViewCell 



- (void)awakeFromNib {
    self.qtyTextField.delegate = self;
}

// Delegate method for tableview cell - quantity text field is within cell.
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    long quantity = [string integerValue];

    [self.delegate updatedQty:[NSNumber numberWithLong:quantity] fromCell:self];
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
