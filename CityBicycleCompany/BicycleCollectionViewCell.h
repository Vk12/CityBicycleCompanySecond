//
//  BicycleCollectionViewCell.h
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 12/1/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BicycleCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *bicycleImageView;
@property (strong, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
