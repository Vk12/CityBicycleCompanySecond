//
//  Photo.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/1/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@dynamic productPhoto;
@dynamic bicycle;
@dynamic accessory;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName
{
    return @"Photo";
}

@end
