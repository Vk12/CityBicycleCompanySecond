//
//  ProductViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

//View Controllers
#import "ProductViewController.h"
#import "BicycleViewController.h"
#import "AccessoriesViewController.h"
#import "ProfileViewController.h"
#import "ShoppingCartViewController.h"

//Model Classes
#import "Bicycle.h"
#import "ChosenBike.h"
#import "Accessory.h"

//Custom Cells
#import "AccessoryCollectionViewCell.h"
#import "BicycleCollectionViewCell.h"
#import "ProductCollectionViewCell.h"

//Frameworks
#import <Parse/Parse.h>
//#import <pop/POP.h>
#import "Cart.h"

////Animations
//#import "PresentingAnimator.h"
//#import "DismissingAnimator.h"
#import "ModalViewController.h"

//Media
@import MediaPlayer;

#define kImageAspectRatioScale 0.65625
#define kSplashVideoPlayed @"ranOnce"


@interface ProductViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *productCollectionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIButton *shoppingCartButton;
//Changed to uiView from UIButton for pop animation in profileButtonPressed Method
@property (strong, nonatomic) IBOutlet UIView *profileButton;
@property (strong, nonatomic) IBOutlet UILabel *shoppingCartCounter;


@property NSArray *bicycleArray;
@property NSArray *accessoryArray;
@property NSArray *currentProductsArray;
@property Cart *singleton;


@end

@implementation ProductViewController

-(void)showSplashVideo
{
    //check to see if NSUSERDEFAULTS contains YES for key: kSplashVideoPlayed
    //if yes, dont play video
    //if no, play video, and then set the vale for key: kSplashVideoPlayed to YES


    //UIViewController *modalSplashVideoViewController = [[UIViewController alloc] init];

    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kSplashVideoPlayed] boolValue]) {

        CGFloat screenSize = [[UIApplication sharedApplication] keyWindow].frame.size.height;
        NSString *filename = @"videoSplashSixPlus.mp4";


        if (screenSize == 480) {
            filename = @"splashVideoFourS.mp4";
            NSLog(@"4 video ran");
        }
        else if (screenSize == 568)
        {
            filename = @"splashVideofive.mp4";
        }
        else if (screenSize == 667)
        {
            filename = @"splashvideoSix.mp4";
        }
        else if (screenSize == 736)
        {
            filename = @"videoSplashSixPlus.mp4";
        }
        
        
    


        

        NSString *moviepath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];

        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:moviepath]];
        controller.moviePlayer.controlStyle = MPMovieControlStyleNone;
        [controller.moviePlayer prepareToPlay];
        [controller.moviePlayer play];

        [self presentMoviePlayerViewControllerAnimated:controller];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:kSplashVideoPlayed];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

//    NSString *moviepath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"splashvideo.mp4"];
//
//    MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:moviepath]];
//    controller.moviePlayer.controlStyle = MPMovieControlStyleNone;
//    [controller.moviePlayer prepareToPlay];
//    [controller.moviePlayer play];
//
//    [self presentMoviePlayerViewControllerAnimated:controller];




    //moviePlayer.controlStyle = MPMovieControlStyleFullscreen;

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    //[moviePlayer play];


    //modalSplashVideoViewController.view = moviepath;

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"cartChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.singleton = [Cart sharedManager];
        [self.shoppingCartCounter setText:[NSString stringWithFormat:@"%lu", (unsigned long)self.singleton.cartArray.count]];
        [self upDateCartColorCounter];
    }];
}

-( void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showSplashVideo];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"cartChanged" object:nil];
}
- (void)upDateCartColorCounter
{
    if (self.singleton.cartArray.count > 0) {
        self.shoppingCartCounter.textColor = [UIColor redColor];
    }
}
#pragma mark - UIViewControllerTransitioningDelegate
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
//{
//    return [PresentingAnimator new];
//
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    return  [DismissingAnimator new];
//}


#pragma mark - Private Instance methods

//- (void)addPresentButton
//{
//    UIButton *presentButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    presentButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [presentButton setTitle:@"Present Modal View Controller" forState:UIControlStateNormal];
//    [presentButton addTarget:self action:@selector(present:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:presentButton];
//
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:presentButton
//                                                          attribute:NSLayoutAttributeCenterX
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.view
//                                                          attribute:NSLayoutAttributeCenterX
//                                                         multiplier:1.f
//                                                           constant:0.f]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:presentButton
//                                                          attribute:NSLayoutAttributeCenterY
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.view
//                                                          attribute:NSLayoutAttributeCenterY
//                                                         multiplier:1.f
//                                                           constant:0.f]];
//
//}

- (void)present:(id)sender
{
    ModalViewController *modalViewController = [ModalViewController new];
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationCustom;

    [self presentViewController:modalViewController
                                            animated:YES
                                          completion:nil];
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
    [self.shoppingCartCounter setText:[NSString stringWithFormat:@"%lu", (unsigned long)self.singleton.cartArray.count]];

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
    //PFObject *name;



    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        Bicycle *bike = self.bicycleArray [indexPath.row];
        file = bike.bicyclePhoto;
        productCell.productName.text = bike.name;
    }
    else
    {
        Accessory *accessory = self.accessoryArray [indexPath.row];
        file = accessory.accessoryPhoto;
        productCell.productName.text = accessory.name;
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
        BicycleViewController *vc = [BicycleViewController newFromStoryboard];

        vc.transitioningDelegate = self;
        vc.modalPresentationStyle = UIModalPresentationCustom;

        //NSInteger bicycleIndexSelected = [self.productCollectionView indexPathForCell:sender].row;
        //NSInteger bicycleIndexSelected = [self.productCollectionView indexPathForCell:indexPath.row];


        //NSInteger bicycleIndexSelected = [self.productCollectionView indexPathForCell:indexPath.row];
        NSInteger bicycleIndexSelected = [self.productCollectionView indexPathForCell:cell].row;
        Bicycle *theBike = [self.bicycleArray objectAtIndex:bicycleIndexSelected];
        vc.bicycleFromParse = theBike;

        [self presentViewController:vc
                           animated:YES
                         completion:nil];


    }
    else
    {
        AccessoriesViewController *vc = [AccessoriesViewController newFromStoryboard];

        vc.transitioningDelegate = self;
        vc.modalPresentationStyle = UIModalPresentationCustom;

        NSInteger accessoriesIndexSelected = [self.productCollectionView indexPathForCell:cell].row;
        Accessory *theAccessory = [self.accessoryArray objectAtIndex:accessoriesIndexSelected];
        vc.accessoryFromParse = theAccessory;

        [self presentViewController:vc
                           animated:YES
                         completion:nil];
    }


}

- (IBAction)profileButtonTapped:(id)sender {

//    POPSpringAnimation *profileButtonAnimation = [POPSpringAnimation animation];
//    profileButtonAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerSize];
//    profileButtonAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(25, 25)];
//    profileButtonAnimation.springBounciness = 10.0;
//    profileButtonAnimation.springSpeed = 10.0;
//
//    [profileButtonAnimation pop_addAnimation:self.profileButton forKey:@"profileButtonPop"];

    ProfileViewController *vc = [ProfileViewController newFromStoryboard];

//    vc.transitioningDelegate = self;
//    vc.modalPresentationStyle = UIModalPresentationCustom;

    [self presentViewController:vc
                       animated:YES
                     completion:nil];



}

- (IBAction)shoppingCartButtonTapped:(id)sender {

    ShoppingCartViewController *vc = [ShoppingCartViewController newFromStoryboard];

    vc.transitioningDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationCustom;

    [self presentViewController:vc animated:YES completion:nil];
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
