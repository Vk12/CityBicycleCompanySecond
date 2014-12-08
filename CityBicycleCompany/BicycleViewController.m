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
#import "ShoppingCartViewController.h"
#import "Cart.h" // Singleton class

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
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *rearBreakLabel;
@property (strong, nonatomic) IBOutlet UILabel *wheelSetColor;
@property (strong, nonatomic) IBOutlet UILabel *extraCityWheelsetLabel;
@property (strong, nonatomic) IBOutlet UILabel *shoppingCartCounterLabel;

@property ChosenBike *localChosenBike;
@property Cart *singleton;
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
    [self.quantityTextField setDelegate:self];
    self.singleton = [Cart sharedManager];
    [self.shoppingCartCounterLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)self.singleton.cartArray.count]];
    
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
- (IBAction)onCartButtonTapped:(UIButton *)sender
{
//    self shouldPerformSegueWithIdentifier:@"bicycleToCartSegue" sender:sender
//    if (<#condition#>) {
//        <#statements#>
//    }
}

//-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if (self.sizeSegmentedController.selectedSegmentIndex >= 0 && self.wheelSetColorSegmented.selectedSegmentIndex >= 0 && self.classicSeriesWheelsetSegmented.selectedSegmentIndex >= 0 && self.rearBreakController.selectedSegmentIndex >= 0)
//    {
//        [self performSegueWithIdentifier:@"bicycleToCartSegue" sender:sender];
//        return YES;
//    } else
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"City Bicycle Company"
//                                                        message:@"Please select all items before proceding"
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return NO;
//        
//    }
//}

- (IBAction)dismissOnTapped:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    
    if (self.sizeSegmentedController.numberOfSegments == 0)
    {
        [self.sizeSegmentedController removeAllSegments];
        self.sizeSegmentedController.hidden = YES;
        self.sizeLabel.hidden = YES;
    }
    
    for (NSString *wheelSetColor in self.bicycleFromParse.wheelsetColor)
    {
        [self.wheelSetColorSegmented insertSegmentWithTitle:wheelSetColor atIndex:i animated:YES];
        i++;
    }
    
    if (self.wheelSetColorSegmented.numberOfSegments == 0)      
    {
        [self.wheelSetColorSegmented removeAllSegments];
        self.wheelSetColorSegmented.hidden = YES;
        self.wheelSetColor.hidden = YES;
    }
    
    for (NSString *classicSeries in self.bicycleFromParse.extraWheel)
    {
        [self.classicSeriesWheelsetSegmented insertSegmentWithTitle:classicSeries atIndex:i animated:YES];
        i++;
    }
    if (self.classicSeriesWheelsetSegmented.numberOfSegments == 0)
    {
        [self.classicSeriesWheelsetSegmented removeAllSegments];
        self.classicSeriesWheelsetSegmented.hidden = YES;
        self.extraCityWheelsetLabel.hidden = YES;
    }
}


- (IBAction)onCartButtonPressed:(UIButton *)sender
{
    self.localChosenBike.chosenName = self.bicycleFromParse.name;
    if (self.sizeSegmentedController.selectedSegmentIndex == -1 && self.sizeSegmentedController.hidden == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"City Bicycle Company"
                                                        message:@"Please select a size"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"City Bicycle Company"
                                                        message:@"Please enter quantity"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
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
    
    self.localChosenBike.chosenPrice = self.bicycleFromParse.originalPrice;
    
    [self.addToCartArray addObject:self.localChosenBike];
    
    
    [self.singleton addItemToCart:self.localChosenBike];
    

    [self.shoppingCartCounterLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)self.singleton.cartArray.count]];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.quantityTextField resignFirstResponder];
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"bicycleToCartSegue"])
    {
        ShoppingCartViewController *vc = segue.destinationViewController;
        ChosenBike *chosenBike = [[ChosenBike alloc]init];
        chosenBike.passTheBikeArray = self.addToCartArray;
        vc.theChosenBike = chosenBike;
    }
    
}

//BicycleViewController *vc = [segue destinationViewController];
//NSInteger bicycleIndexSelected = [self.productCollectionView indexPathForCell:sender].row;
//Bicycle *theBike = [self.bicycleArray objectAtIndex:bicycleIndexSelected];
//vc.bicycleFromParse = theBike;






@end
