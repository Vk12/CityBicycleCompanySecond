//
//  ChosenBike.h
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/2/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChosenBike : NSObject

@property (strong, nonatomic) NSString *chosenSize;
@property (strong ,nonatomic) NSString *chosenWheelSetColor;
@property (strong, nonatomic) NSString *extraSeriesWheelset;
@property (strong, nonatomic) NSNumber *chosenQuantity;
@property (strong, nonatomic) NSString *chosenBike;
@property (strong, nonatomic) NSString *salePrice;
@property (strong, nonatomic) NSString *chosenName;
@property (strong, nonatomic) NSNumber *chosenPrice;
@property BOOL bicycleHasRearBrake;
@property NSArray *passTheBikeArray;
//@property (strong, nonatomic)

@end
