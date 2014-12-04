//
//  ChosenAccessory.h
//  CityBicycleCompany
//
//  Created by Supreme Overlord on 12/3/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChosenAccessory : NSObject

@property (strong, nonatomic) NSString *chosenName;
@property (strong, nonatomic) NSString *salePrice;
@property (strong, nonatomic) NSNumber *chosenQuantity;
@property (strong, nonatomic) NSString *chosenAccessory;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *chosenSize;
@property (strong, nonatomic) NSArray *passTheAccessoryArray;
@end
