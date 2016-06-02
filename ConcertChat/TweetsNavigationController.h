//
//  TweetsViewController.h
//  ConcertChat
//
//  Created by Logan O'Connell on 5/26/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "ConcertChat.h"

#import "ViewController.h"

@interface TweetsNavigationController : UINavigationController
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) BOOL hasSearch;
@end