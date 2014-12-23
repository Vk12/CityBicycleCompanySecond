//
//  ChosenAccessory.m
//  CityBicycleCompany
//
//  Created by Supreme Overlord on 12/3/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "ChosenAccessory.h"

@implementation ChosenAccessory

- (NSDictionary *)encodeForUserDefaults
{
    // We can't use custom objects in NSUserDefaults.  The workaround is to encode our custom object properties into a dictionary.
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.chosenQuantity forKey:@"chosenQuantity"];
    [dictionary setObject:self.chosenName forKey:@"chosenName"];
//    [dictionary setObject:self.salePrice forKey:@"salePrice"];
//    [dictionary setObject:self.chosenAccessory forKey:@"chosenAccessory"];
    [dictionary setObject:self.color forKey:@"color"];
    [dictionary setObject:self.chosenSize forKey:@"chosenSize"];
//    [dictionary setObject:self.passTheAccessoryArray forKey:@"passTheAccessoryArray"];
    [dictionary setObject:self.chosenPrice forKey:@"chosenPrice"];
    return dictionary;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    // After saving to NSUserDefaults, we need to "unpack" the NSDictionary so that we can put it back into the array.
    self = [super init];
    
    self.chosenQuantity = dictionary[@"chosenQuantity"];
    self.chosenName = dictionary[@"chosenName"];
//    self.salePrice = dictionary[@"salePrice"];
//    self.chosenAccessory = dictionary[@"chosenAccessory"];
    self.color = dictionary[@"color"];
    self.chosenSize = dictionary[@"chosenSize"];
//    self.passTheAccessoryArray = dictionary[@"passTheAccessoryArray"];
    self.chosenPrice = dictionary[@"chosenPrice"];
    return self;
}

@end
