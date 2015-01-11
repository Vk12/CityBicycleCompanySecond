//
//  AccessoryCollectionViewCell.h
//  CityBicycleCompany
//
//  Created by Supreme Overlord on 12/3/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccessoryCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (strong, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
