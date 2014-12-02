//
//  ProductViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductCollectionViewCell.h"
#import <Parse/Parse.h>
#import "BicycleViewController.h"
#import "BicycleCollectionViewCell.h"
#import "ChosenBike.h"
@interface ProductViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *productCollectionView;
@property (strong, nonatomic) IBOutlet UIButton *accessoriesButton;
@property NSArray *productArray;
@end

@implementation ProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self queryAllObjects];
}

- (void)queryAllObjects
{
    PFQuery *query = [PFQuery queryWithClassName:@"Bicycle"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            self.productArray = objects;
            [self.productCollectionView reloadData];
        }
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"productCell" forIndexPath:indexPath];
    PFObject *bikeImage = self.productArray [indexPath.row];
    PFFile *file = [bikeImage objectForKey:@"bicyclePhoto"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cell.imageView.image = [UIImage imageWithData:data];
    }];
    

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productArray.count;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(ProductCollectionViewCell *)sender
{
    BicycleViewController *vc = [segue destinationViewController];
    NSInteger bicycleIndexSelected = [self.productCollectionView indexPathForCell:sender].row;
    ChosenBike *theBike = [self.productArray objectAtIndex:bicycleIndexSelected];
    vc.theChosenBicycleInformation = theBike;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
