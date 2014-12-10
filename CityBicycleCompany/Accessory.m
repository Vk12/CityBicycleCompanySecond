//
//  Accessory.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/1/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "Accessory.h"

@implementation Accessory
@dynamic name;
@dynamic color;
@dynamic accessoryDescription;
@dynamic detailSale;
@dynamic accessoryPhoto;
@dynamic originalPrice;
@dynamic quantity;
@dynamic salePrice;
@dynamic size;
@dynamic isOnSale;
+ (void) load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Accessory";
}

@end
