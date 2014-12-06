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

//NSMutableArray *cartArray;

static Cart *sharedInstance;

+ (Cart *)sharedManager
{
//    Cart *cartObject = [[Cart alloc]init];
////    self.cartArray = [NSMutableArray new];
//    return cartObject;

    if (!sharedInstance)
    {
        sharedInstance = [[Cart alloc] init];
        sharedInstance.cartArray = [NSMutableArray new];
        //        cartArray = [NSMutableArray new];
    }
    return sharedInstance;
}
- (void)addItemToCart:(id)object
{
    if(!self.cartArray){
    
        self.cartArray = [NSMutableArray new];
    }
    
    [self.cartArray addObject:object];
}
- (void)removeItemFromCart:(id)object
{
    [self.cartArray removeObject:object];
}
- (void)emptyAllItemsFromCart:(id)object
{
    [self.cartArray removeAllObjects];
}


@end
