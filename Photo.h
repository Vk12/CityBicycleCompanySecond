//
//  Photo.h
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/1/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <Parse/Parse.h>
@class Bicycle;
@class Accessory;
@interface Photo : PFObject <PFSubclassing>

@property PFFile *productPhoto;
@property Bicycle *bicycle;
@property Accessory *accessory;

@end
