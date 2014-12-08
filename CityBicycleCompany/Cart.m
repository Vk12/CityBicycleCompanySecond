//
//  Cart.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/2/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "Cart.h"

@implementation Cart

// @property NSMutableArray *cartArray;

//NSMutableArray *cartArray;

static Cart *sharedInstance;

+ (Cart *)sharedManager
{
//    Cart *cartObject = [[Cart alloc]init];
////    self.cartArray = [NSMutableArray new];
//    return cartObject;

    if (!sharedInstance)
    {
        sharedInstance = [[Cart alloc] init];
        sharedInstance.cartArray = [NSMutableArray new];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:sharedInstance.cartArray forKey:@"tableViewCartData"];
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
}
- (void)removeItemFromCart:(id)object
{
    [self.cartArray removeObject:object];
}
- (void)emptyAllItemsFromCart:(id)object
{
    [self.cartArray removeAllObjects];
}


- (void)save
{   // This method SAVES / stores the information.
    // This method gets the standardUserDefault obj´ects, stores the UITableView cartArray data against a key, synchronizes the defaults.
//    self.cartArray = [NSMutableArray new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  // gets shared user defaults
    [userDefaults setObject:[self.cartArray copy] forKey:@"tableViewCartData"];
    [userDefaults synchronize];
    NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"cartItems.plist"];
    [[self.cartArray copy] writeToURL:plistURL atomically:YES];
}
-(void)load
{
    // This method LOADS / retrieves the information.
    NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"cartItems.plist"];
    // This URL points to the location of cartItems.plist.
    // If cartItems.plist doesn't yet exist, it will be created.  If it already exists, it will be overwritten.
    // cartItems.plist is a file that gets created in Documents Directory.  In the save method, there will be a writeToURL:cartItems.plist.
    self.cartArray = [NSMutableArray arrayWithContentsOfURL:plistURL];
    if (self.cartArray == nil)
    {
        self.cartArray = [NSMutableArray new];
    }
}
-(NSURL *)documentsDirectory
{   // This method returns a directory URL of NSDocumentDirectory (Documents Directory) I think.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}

@end
