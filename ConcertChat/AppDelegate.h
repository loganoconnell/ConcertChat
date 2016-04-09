//
//  AppDelegate.h
//  ConcertChat
//
//  Created by Logan O'Connell on 4/4/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "ConcertChat.h"
#import "MPCManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) MPCManager *manager;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@end