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

    if (self.sizeSegmentedController.selectedSegmentIndex == 0)
    {
        NSString *firstSegment = [NSString stringWithFormat:@"50 cm"];
        
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
