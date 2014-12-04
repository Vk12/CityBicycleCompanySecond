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
#import "Photo.h"
@interface BicycleViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
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
@property NSMutableArray *bicycleImageArray;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property ChosenBike *localChosenBike;
@end

@implementation BicycleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUserInterfaceWithOurBikeFromParse];
    self.localChosenBike = [[ChosenBike alloc]init];
    self.bicycleImageArray = [@[]mutableCopy];
    self.addToCartArray = [@[]mutableCopy];
    [self queryImages];
    [self.wheelSetColorSegmented setSelectedSegmentIndex:0];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
        
    self.widthConstraint.constant = self.scrollView.frame.size.width;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.scrollView.frame.size.width, self.collectionView.frame.size.height);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)updateUserInterfaceWithOurBikeFromParse
{
    self.nameLabel.text = self.bicycleFromParse.name;
    self.descriptionLabel.text = self.bicycleFromParse.bicycleDescription;
    int i = 0;
    [self.sizeSegmentedController removeAllSegments];
    [self.wheelSetColorSegmented removeAllSegments];
    [self.classicSeriesWheelsetSegmented removeAllSegments];
    
    for (NSString *size in self.bicycleFromParse.size )
    {
        
        [self.sizeSegmentedController insertSegmentWithTitle:size atIndex:i animated:YES];
        i++;
    }
    for (NSString *wheelSetColor in self.bicycleFromParse.wheelsetColor)
    {
        [self.wheelSetColorSegmented insertSegmentWithTitle:wheelSetColor atIndex:i animated:YES];
        i++;
    }
    
    for (NSString *classicSeries in self.bicycleFromParse.extraWheel)
    {
        [self.classicSeriesWheelsetSegmented insertSegmentWithTitle:classicSeries atIndex:i animated:YES];
        i++;
    }
    
}


- (IBAction)onCartButtonPressed:(UIButton *)sender
{
    self.localChosenBike.chosenName = self.bicycleFromParse.name;
    if (self.sizeSegmentedController.selectedSegmentIndex == -1)
    {
        NSLog(@"Its broken!");
    }else
    {
        self.localChosenBike.chosenSize = self.bicycleFromParse.size[self.sizeSegmentedController.selectedSegmentIndex];
    }
    
    
    if (self.classicSeriesWheelsetSegmented.selectedSegmentIndex == -1)
    {
        NSLog(@"Add an extra Wheelset");
    }else
    {
        self.localChosenBike.extraSeriesWheelset = self.bicycleFromParse.extraWheel[self.classicSeriesWheelsetSegmented.selectedSegmentIndex];
    }
    
    if (![self.quantityTextField.text isEqualToString:@""])
    {
        NSNumberFormatter *quantityConversion = [[NSNumberFormatter alloc]init];
        [quantityConversion setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber *myNumber = [quantityConversion numberFromString:self.quantityTextField.text];
        self.localChosenBike.chosenQuantity = myNumber;
    }
    else
    {
        NSLog(@"Add a number to the quantity!");
    }
    
    if (self.rearBreakController.selectedSegmentIndex == 1)
    {
        self.bicycleFromParse.hasRearBreak = YES;
        self.localChosenBike.bicycleHasRearBrake = self.bicycleFromParse.hasRearBreak;
    }
    else
    {
        self.bicycleFromParse.hasRearBreak = NO;
        self.localChosenBike.bicycleHasRearBrake = self.bicycleFromParse.hasRearBreak;
    }
    
    self.localChosenBike.chosenWheelSetColor = self.bicycleFromParse.wheelsetColor[self.wheelSetColorSegmented.selectedSegmentIndex];
    
    [self.addToCartArray addObject:self.localChosenBike];
    
    
}

- (void)queryImages
{
    PFQuery *queryImages = [Photo query];
    [queryImages whereKey:@"bicycle" equalTo:self.bicycleFromParse];
    [queryImages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (Photo *photo in objects) {
                [self.bicycleImageArray addObject:photo.productPhoto];
            }

            [self.collectionView reloadData];
            self.pageControl.numberOfPages = self.bicycleImageArray.count;
        }
        else
        {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
     
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BicycleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bicycleCell" forIndexPath:indexPath];
    
    PFFile *file = self.bicycleImageArray[indexPath.row];

    if (!file.isDataAvailable)
    {
        cell.bicycleImageView.alpha = 0;
    }
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        cell.bicycleImageView.image = [UIImage imageWithData:data];
        [UIView animateWithDuration:.2 animations:^{
            cell.bicycleImageView.alpha = 1;
        }];

    }];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bicycleImageArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int pageNumber = roundf( self.collectionView.contentOffset.x/self.collectionView.frame.size.width );
    self.pageControl.currentPage = pageNumber;
}











@end
