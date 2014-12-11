//
//  Cart.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/2/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "Cart.h"
#import "Bicycle.h"
#import "Accessory.h"
#import "ChosenAccessory.h"
#import "ChosenBike.h"
@implementation Cart

static Cart *sharedInstance;

- (id) init
{
    self = [super init];
    self.cartArray = [NSMutableArray new];
    [self load];
    return self;
}
+ (Cart *)sharedManager
{

    if (!sharedInstance)
    {
        sharedInstance = [[Cart alloc] init];
    }
    return sharedInstance;
}
- (void)addItemToCart:(id)object
{
    if(!self.cartArray){
    
        self.cartArray = [NSMutableArray new];
//        [self save];
    }
    
    [self.cartArray addObject:object];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cartChanged" object:nil];

    
}
- (void)removeItemFromCart:(id)object
{
    [self.cartArray removeObject:object];
}
- (void)emptyAllItemsFromCart:(id)object
{
    [self.cartArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cartChanged" object:nil];

    
}
// Ni hao ma?
// Wo yao qu cesuo.
// Xie xie.

- (void)save
{   // This method SAVES / stores the information.
    // This method also:
    //      gets the standardUserDefault objects
    //      gets every object in cartArray and puts it into an cartICanSave (b/c self.cartArray contains different objects from custom classes - can't put into plist)
    //      synchronizes the defaults.

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  // gets shared user defaults
    
    NSMutableArray *cartICanSave = [NSMutableArray array];
    for (id item in self.cartArray)
    {
        if ([item isMemberOfClass:[ChosenBike class]])
        {
            ChosenBike *aBike = item;
            [cartICanSave addObject:[aBike encodeForUserDefaults]];
            
        }
        else if ([item isMemberOfClass:[ChosenAccessory class]])
        {
            ChosenAccessory *anAccessory = item;
            NSDictionary *dict = [anAccessory encodeForUserDefaults];
            [cartICanSave addObject:dict];
            
        }
    }
    [userDefaults setObject:cartICanSave forKey:@"tableViewCartData"];
    [userDefaults synchronize];
    
}
-(void)load
{
    [self.cartArray removeAllObjects];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  // gets shared user defaults
    
    // gets objects in tableViewCartData and puts into items array
    NSArray *items = [userDefaults objectForKey:@"tableViewCartData"];
    
    // iterates through items and puts into NSDictionary
    for (NSDictionary *d in items)
    {
        // Figure out whether I have a bike or an accessory
        // I only have to do this check once for a property that ChosenBike and ChosenAccessory do not share.
        if (d[@"chosenWheelSetColor"])
        {
            // I must have a bike
            ChosenBike *aBike = [[ChosenBike alloc] initWithDictionary:d];
            [self.cartArray addObject:aBike];
        }
        else
        {
            // I must have an accessory
            ChosenAccessory *aAccessory = [[ChosenAccessory alloc] initWithDictionary:d];
            [self.cartArray addObject:aAccessory];
            
        }
    }
    
}
-(NSURL *)documentsDirectory
{   // This method returns a directory URL of NSDocumentDirectory (Documents Directory) I think.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}

@end
