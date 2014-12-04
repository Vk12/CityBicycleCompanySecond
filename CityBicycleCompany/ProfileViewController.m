//
//  ProfileViewController.m
//  CityBicycleCompany
//
//  Created by Vala Kohnechi on 11/26/14.
//  Copyright (c) 2014 MVA. All rights reserved.
//

#import "ProfileViewController.h"
#import <MessageUI/MessageUI.h> 
#import <MessageUI/MFMailComposeViewController.h>

@interface ProfileViewController ()<MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) IBOutlet UISwitch *salesSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *productsSwitch;
@property (strong, nonatomic) IBOutlet UIButton *adminLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *signoutButton;
@property (strong, nonatomic) MFMailComposeViewController *mailCount;
@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mailCount = [[MFMailComposeViewController alloc]init];
}
- (IBAction)onEmailButtonTapped:(UIButton *)sender
{
    [self sendEmail];
}
- (IBAction)callPhone:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:8554347082"]];
}

-(void)sendEmail {
    
    if([MFMailComposeViewController canSendMail])
    {
        
        self.mailCount.mailComposeDelegate = self;
        [self.mailCount setSubject:@"Email Us!"];
        [self.mailCount setToRecipients:[NSArray arrayWithObject:@"support@citybicycleco.com"]];
        [self.mailCount setMessageBody:@"Email message" isHTML:NO];
        
        [self presentViewController:self.mailCount animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onWebsiteButtonPressed:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.citybicycleco.com"]];

}

- (IBAction)onSwitchSalesNotificationToggle:(UISwitch *)sender {
}

- (IBAction)onSwitchNewProductsNotificationToggle:(id)sender {
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
