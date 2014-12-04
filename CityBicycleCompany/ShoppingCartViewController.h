//
//  ShoppingCartViewController.h
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChosenAccessory.h"
#import "ChosenBike.h"

@interface ShoppingCartViewController : UIViewController

@property ChosenBike *theChosenBike;
@property ChosenAccessory *theChosenAccessory;
@end
