//
//  Bicycle.h
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/1/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <Parse/Parse.h>

@interface Bicycle : PFObject <PFSubclassing>

@property NSArray *wheelsetColor;
@property NSString *coordinatePosition;
@property NSString *bicycleDescription;
@property NSArray *handleBars;
@property BOOL hasAluminumAlloy;
@property BOOL hasRearBreak;
@property BOOL isOnSale;
@property NSString *name;
@property NSNumber *originalPrice;
@property NSString *pedalStrap;
@property NSNumber *quantity;
@property NSNumber *saleDetail;
@property NSNumber *salePrice;
@property NSArray *size;
@property PFFile *bicyclePhoto;
@property NSArray *extraWheel;

@end
