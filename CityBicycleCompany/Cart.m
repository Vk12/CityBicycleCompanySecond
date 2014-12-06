//
//  Cart.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/2/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "Cart.h"

@implementation Cart

// @property NSMutableArray *cartArray;

NSMutableArray *cartArray;

+ (Cart *)sharedManager
{
    Cart *cartObject = [[Cart alloc]init];
    cartArray = [NSMutableArray new];
    return cartObject;

}

- (void)addItemToCart:(id)object
{
//    if(!cartArray){
//    
//        cartArray = [NSMutableArray new];
//    }
//    
    [cartArray addObject:object];


}
- (void)removeItemFromCart:(id)object{}
- (void)emptyAllItemsFromCart:(id)object{}

@end
