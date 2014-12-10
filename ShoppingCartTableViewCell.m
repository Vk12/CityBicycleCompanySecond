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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int quantity = [string integerValue];

    [self.delegate updatedQty:[NSNumber numberWithInt:quantity] fromCell:self];
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
