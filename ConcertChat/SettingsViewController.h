//
//  SettingsViewController.h
//  ConcertChat
//
//  Created by Logan O'Connell on 4/6/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "ConcertChat.h"

#import "ViewController.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *settingsTableView;
@end