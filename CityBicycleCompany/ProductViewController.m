//
//  ProductViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "Bicycle.h"
#import "ProductViewController.h"
#import "ProductCollectionViewCell.h"
#import <Parse/Parse.h>
#import "BicycleViewController.h"
#import "AccessoriesViewController.h"
#import "BicycleCollectionViewCell.h"
#import "ChosenBike.h"
#import "Accessory.h"
#import "AccessoryCollectionViewCell.h"
#import <pop/POP.h>

#define kImageAspectRatioScale 0.65625

@interface ProductViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *productCollectionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIButton *shoppingCartButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;


@property NSArray *bicycleArray;
@property NSArray *accessoryArray;
@property NSArray *currentProductsArray;

@end

@implementation ProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.productCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.productCollectionView.frame.size.width, (self.productCollectionView.frame.size.width * kImageAspectRatioScale));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self queryAllObjects];


}

- (void)queryAllObjects
{
    PFQuery *bicycleQuery = [PFQuery queryWithClassName:@"Bicycle"];
    [bicycleQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            self.bicycleArray = objects;
            [self refreshCollectionViewData];
        }
    }];

    PFQuery *accessoryQuery = [PFQuery queryWithClassName:@"Accessory"];
    [accessoryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            self.accessoryArray = objects;
            [self refreshCollectionViewData];
        }
    }];
}


- (IBAction)onSegmentControlPressed:(UISegmentedControl *)sender
{

    [self refreshCollectionViewData];
    
}


- (void)refreshCollectionViewData
{
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        self.currentProductsArray = self.bicycleArray;

    } else
    {
        self.currentProductsArray = self.accessoryArray;
    }

    [self.productCollectionView reloadData];
}


#pragma mark CollectionView Delegates

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCollectionViewCell *productCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"productCell" forIndexPath:indexPath];
    PFFile *file;


    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        Bicycle *bike = self.bicycleArray [indexPath.row];
        file = bike.bicyclePhoto;
    }
    else
    {
        Accessory *accessory = self.accessoryArray [indexPath.row];
        file = accessory.accessoryPhoto;
    }

    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        productCell.imageView.image = [UIImage imageWithData:data];
    }];


    return productCell;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.currentProductsArray.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        [self performSegueWithIdentifier:@"bicycleSegue" sender:cell];

    }
    else
    {
        [self performSegueWithIdentifier:@"accessorySegue" sender:cell];
    }


}


#pragma mark Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"bicycleSegue"])
    {
        BicycleViewController *vc = [segue destinationViewController];
        NSInteger bicycleIndexSelected = [self.productCollectionView indexPathForCell:sender].row;
        Bicycle *theBike = [self.bicycleArray objectAtIndex:bicycleIndexSelected];
        vc.bicycleFromParse = theBike;
        
    }
    else if ([segue.identifier isEqual:@"accessorySegue"] )
    {
        AccessoriesViewController *vc = [segue destinationViewController];
        NSInteger accessoryIndexSelected = [self.productCollectionView indexPathForCell:sender].row;
        Accessory *theAccessory = [self.accessoryArray objectAtIndex:accessoryIndexSelected];
        vc.accessoryFromParse = theAccessory;

    }
    else if ([segue.identifier isEqual:@"settingsToProfileSegue"])
    {
        
    }
   

}



@end
