//
//  BicycleViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "BicycleViewController.h"
#import "BicycleCollectionViewCell.h"
#import <Parse/Parse.h>
#import "Bicycle.h"
@interface BicycleViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sizeSegmentedController;
@property (strong, nonatomic) IBOutlet UISegmentedControl *rearBreakController;
@property (strong, nonatomic) IBOutlet UISegmentedControl *wheelSetColorSegmented;
@property (strong, nonatomic) IBOutlet UISegmentedControl *classicSeriesWheelsetSegmented;
@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;
@property (strong, nonatomic) IBOutlet UIButton *addtoCartButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property NSArray *bikeArray;
@property NSMutableArray *addToCartArray;
@end

@implementation BicycleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getImages];
}

- (void) getImages
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query getObjectInBackgroundWithId:@"7EVNkO14kE" block:^(PFObject *object, NSError *error)
    {
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }else{
            self.bikeArray = [NSArray arrayWithObjects:object, nil];
            [self.collectionView reloadData];
        }
    } ];
}

- (IBAction)onCartButtonPressed:(UIButton *)sender
{
    Bicycle *bicycle = [[Bicycle alloc]init];
    bicycle.size = [NSArray arrayWithObjects:@"50cm (5'2 - 5'6)",@"55cm (5'7 - 5'10)",@"60cm (5'11 - 6'4)", nil];
    bicycle.wheelsetColor = [NSArray arrayWithObjects:@"Black",@"Red ($15)",@"White ($15)", @"Gold ($80)", nil];
    bicycle.extraWheel = [NSArray arrayWithObjects:@"Red ($80)",@"White ($80)",@"Gold ($80)", nil];
    
    //Sizes
    if (self.sizeSegmentedController.selectedSegmentIndex == 0)
    {
//        bicycle.size = [NSArray arrayWithObject:]
        
    }
    else if (self.sizeSegmentedController.selectedSegmentIndex == 1)
    {
//        bicycle.size = [NSArray arrayWithObject:];
    }
    else if (self.sizeSegmentedController.selectedSegmentIndex == 2)
    {
//        bicycle.size = [NSArray arrayWithObject:];
    }
    
    //Setting RearBreak
    if (self.rearBreakController.selectedSegmentIndex == 0)
    {
        bicycle.hasRearBreak = NO;
    }
    else if (self.rearBreakController.selectedSegmentIndex == 1)
    {
        bicycle.hasRearBreak = YES;
    }
    
    //Setting WheelColor
    if (self.wheelSetColorSegmented.selectedSegmentIndex == 0)
    {
//        bicycle.wheelsetColor = [NSArray arrayWithObject:]
    }
    else if (self.wheelSetColorSegmented.selectedSegmentIndex == 1)
    {
//        bicycle.wheelsetColor = [NSArray arrayWithObject:]
    }
    else if (self.wheelSetColorSegmented.selectedSegmentIndex == 2)
    {
//         bicycle.wheelsetColor = [NSArray arrayWithObject:]
    }
    else if (self.wheelSetColorSegmented.selectedSegmentIndex == 3)
    {
//         bicycle.wheelsetColor = [NSArray arrayWithObject:]
    }
    
    //Setting Extra Classic Wheels
    if (self.classicSeriesWheelsetSegmented.selectedSegmentIndex == 0)
    {
//        bicycle.extraWheel = [NSArray arrayWithObjects
    }
    else if (self.classicSeriesWheelsetSegmented.selectedSegmentIndex == 1)
    {
//        bicycle.extraWheel = [NSArray arrayWithObject:<#(id)#>]
    }
    else if (self.classicSeriesWheelsetSegmented.selectedSegmentIndex == 2)
    {
//        bicycle.extraWheel = [NSArray arrayWithObject:]]
    }
    
//    self.addToCartArray = [NS]
    
}


-(void)viewDidAppear:(BOOL)animated
{
    self.widthConstraint.constant = self.scrollView.frame.size.width;

}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BicycleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bicycleCell" forIndexPath:indexPath];
    
    PFObject *photoObject = self.bikeArray[indexPath.row];
    PFFile *file = [photoObject objectForKey:@"productPhoto"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cell.bicycleImageView.image = [UIImage imageWithData:data];

    }];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bikeArray.count;
}



@end
