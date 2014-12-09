//
//  ChosenBike.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/2/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "ChosenBike.h"

@implementation ChosenBike

- (NSDictionary *)encodeForUserDefaults
{
    // We can't use custom objects in NSUserDefaults.  The workaround is to encode or custom object properites into a dictionary.
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [result setObject:self.chosenQuantity forKey:@"chosenQuantity"];
    [result setObject:self.chosenSize forKey:@"chosenSize"];
    [result setObject:self.chosenWheelSetColor forKey:@"chosenWheelSetColor"];
    [result setObject:self.extraSeriesWheelset forKey:@"extraSeriesWheelset"];
//    [result setObject:self.salePrice forKey:@"salePrice"];
    [result setObject:self.chosenName forKey:@"chosenName"];
    [result setObject:self.chosenPrice forKey:@"chosenPrice"];
//    [result setObject:[NSNumber numberWithBool:self.bicycleHasRearBrake] forKey:@"bicycleHasRearBrake"];
//    [result setObject:self.passTheBikeArray forKey:@"passTheBikeArray"];
    
    return result;
    
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    // After saving to NSUserDefaults, we need to "unpack" the NSDictionary so that we can put it back into an array.
    self = [super init];
    
    self.chosenQuantity = dictionary[@"quantity"];
    self.chosenSize = dictionary[@"chosenSize"];
    self.chosenWheelSetColor = dictionary[@"chosenWheelSetColor"];
    self.extraSeriesWheelset = dictionary[@"extraSeriesWheelset"];
    self.chosenBike = dictionary[@"chosenBike"];
//    self.salePrice = dictionary[@"salePrice"];
    self.chosenName = dictionary[@"chosenName"];
    self.chosenPrice = dictionary[@"chosenPrice"];
//    self.bicycleHasRearBrake = [dictionary[@"bicycleHasRearBrake"] boolValue];
    self.passTheBikeArray = dictionary[@"passTheBikeArray"];
    return self;
}
@end
