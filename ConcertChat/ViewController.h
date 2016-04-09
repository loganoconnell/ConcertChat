//
//  ViewController.h
//  ConcertChat
//
//  Created by Logan O'Connell on 4/4/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "ConcertChat.h"

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "MPCManager.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MPCManagerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *peersTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray<MCPeerID *> *searchResults;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSIndexPath *selectedCellIndex;

@property (nonatomic, strong) NSString *connectedPeerName;

@property (nonatomic) BOOL isAdvertising;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL wantsToBeDisconnected;

- (void)askForNicknameWithError:(BOOL)error;
@end