//
//  AccessoriesViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "AccessoriesViewController.h"
#import <Parse/Parse.h>
#import "AccessoryCollectionViewCell.h"
#import "ChosenAccessory.h"
#import "Photo.h"
#import "Accessory.h"
#import "ShoppingCartViewController.h"
@interface AccessoriesViewController ()<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sizeSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *colorSegmentedControl;
@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;
@property (strong, nonatomic) IBOutlet UIButton *addToCartButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property ChosenAccessory *localChosenAccessory;
@property NSMutableArray *accessoryImageArray;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property NSMutableArray *addToCartArray;
@end

@implementation AccessoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.localChosenAccessory = [[ChosenAccessory alloc]init];
    self.accessoryImageArray = [@[]mutableCopy];
    self.addToCartArray = [@[]mutableCopy];
   
    [self updateUserInterfaceWithOurAccessoryFromParse];
    [self queryImages];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.widthConstraint.constant = self.scrollView.frame.size.width;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.scrollView.frame.size.width, self.collectionView.frame.size.height);
}

- (void)updateUserInterfaceWithOurAccessoryFromParse
{
    self.nameLabel.text = self.accessoryFromParse.name;
    self.descriptionLabel.text = self.accessoryFromParse.accessoryDescription;
    int i = 0;
    [self.sizeSegmentedControl removeAllSegments];
    [self.colorSegmentedControl removeAllSegments];

    
    for (NSString *size in self.accessoryFromParse.size )
    {
        
        [self.sizeSegmentedControl insertSegmentWithTitle:size atIndex:i animated:YES];
        i++;
    }
    for (NSString *color in self.accessoryFromParse.color)
    {
        [self.colorSegmentedControl insertSegmentWithTitle:color atIndex:i animated:YES];
        i++;
    }
    
}


- (void)queryImages
{
    PFQuery *queryImages = [Photo query];
    [queryImages whereKey:@"accessory" equalTo:self.accessoryFromParse];
    [queryImages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (Photo *photo in objects) {
                [self.accessoryImageArray addObject:photo.productPhoto];
            }
            
            [self.collectionView reloadData];
//            self.pageControl.numberOfPages = self.bicycleImageArray.count;
        }
        else
        {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
}
- (IBAction)onAddToCartPressed:(id)sender
{
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AccessoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"accessoryCell" forIndexPath:indexPath];
    PFFile *file = self.accessoryImageArray[indexPath.row];
    
    if (!file.isDataAvailable)
    {
        cell.accessoryImageView.alpha = 0;
    }
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cell.accessoryImageView.image = [UIImage imageWithData:data];
        [UIView animateWithDuration:.2 animations:^{
            cell.accessoryImageView.alpha = 1;
        }];
    }];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.accessoryImageArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int pageNumber = roundf( self.collectionView.contentOffset.x/self.collectionView.frame.size.width );
    self.pageControl.currentPage = pageNumber;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ShoppingCartViewController *vc = segue.destinationViewController;
    ChosenAccessory *chosenAccessory = [[ChosenAccessory alloc]init];
    chosenAccessory.passTheAccessoryArray = self.addToCartArray;
    vc.theChosenBike = chosenAccessory;
}



@end
