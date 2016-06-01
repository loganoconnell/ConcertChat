//
//  TweetsViewController.m
//  ConcertChat
//
//  Created by Logan O'Connell on 5/26/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "TweetsNavigationController.h"

@implementation TweetsNavigationController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *placeholderController = [UIViewController new];
    placeholderController.view.backgroundColor = [UIColor whiteColor];
    self.viewControllers = @[placeholderController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    [self.locationManager requestWhenInUseAuthorization];
    
    if (!self.hasSearch) {
        [self promptForSearch];
    }
}

- (void)promptForSearch {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.customViewColor = UIColorFromRGB(0xF44336);
    
    alert.statusBarHidden = YES;
    
    UITextField *textField = [alert addTextField:@"Concert/artist name"];
    textField.placeholder = @"Concert/artist name";
    
    textField.tintColor = UIColorFromRGB(0xF44336);
    
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    
    [alert addButton:@"OK" actionBlock:^{
        NSString *text = textField.text;
        
        if (text.length > 0) {
            [self showTimelineWithTextToSearch:text];
            
            [textField resignFirstResponder];
            
            self.hasSearch = YES;
        }
        
        else {
            [self promptForSearch];
        }
    }];
    
    [alert addButton:@"Cancel" actionBlock:^{
        [textField resignFirstResponder];
        
        if (!self.hasSearch) {
            [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:0]];
        }
    }];
    
    [alert showEdit:self.tabBarController title:@"View Concert Tweets" subTitle:@"Please enter the concert/artist name." closeButtonTitle:nil duration:0];
}

- (void)showTimelineWithTextToSearch:(NSString *)text {
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    TWTRSearchTimelineDataSource *datasource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:[NSString stringWithFormat:@"%@", text] APIClient:client];
    datasource.geocodeSpecifier = [NSString stringWithFormat:@"%f,%f,100mi", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    
    TWTRTimelineViewController *controller = [[TWTRTimelineViewController alloc] initWithDataSource:datasource];
    controller.title = [NSString stringWithFormat:@"Search \"%@\"", text];
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(promptForSearch)];
    
    self.viewControllers = @[controller];
}
@end