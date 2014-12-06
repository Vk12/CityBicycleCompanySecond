//
//  Cart.h
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/2/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BicycleViewController.h"

@interface Cart : NSObject  // THIS IS OUR SINGLETON CLASS.

+ (Cart *)sharedManager;    // Class method to return the singleton object

- (void)addItemToCart:(id)object;
- (void)removeItemFromCart:(id)object;
- (void)emptyAllItemsFromCart:(id)object;
- (NSMutableArray *)returnArray;

@end
