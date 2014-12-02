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
#import "ChosenBike.h"
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

@property ChosenBike *localChosenBike;
@end

@implementation BicycleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUserInterfaceWithOurBikeFromParse];
    self.localChosenBike = [[ChosenBike alloc]init];
//    self.localChosenBike.chosenName = self.bicycleFromParse.name;
    
//    [self getImages];
//    NSLog(@"hgfhgf %@", self.theChosenBicycleInformation.chosenName);
    
}

- (void)updateUserInterfaceWithOurBikeFromParse
{
    self.nameLabel.text = self.bicycleFromParse.name;
    int i = 0;
    [self.sizeSegmentedController removeAllSegments];
    for (NSString *size in self.bicycleFromParse.size )
    {
        
        [self.sizeSegmentedController insertSegmentWithTitle:size atIndex:i animated:YES];
        i++;
    }
    
}


- (IBAction)onCartButtonPressed:(UIButton *)sender
{
    
    self.localChosenBike.chosenSize = self.bicycleFromParse.size[self.sizeSegmentedController.selectedSegmentIndex];
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
