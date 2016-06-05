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

@interface ViewController : UIViewController <UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MPCManagerDelegate, EAIntroDelegate, CMPopTipViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *peersTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewVerticalLandscapeConstraint;

@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UIImageView *noDataImage;
@property (nonatomic, strong) UILabel *noDataLabel;

@property (nonatomic, strong) NSMutableArray<MCPeerID *> *searchResults;

@property (nonatomic, strong) NSIndexPath *selectedCellIndex;

@property (nonatomic, strong) NSString *connectedPeerName;

@property (nonatomic) BOOL isAdvertising;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL isSearchInLandscape;
@property (nonatomic) BOOL isShowingTutorial;
@property (nonatomic) BOOL isTutorialInLandscape;

- (void)askForNicknameWithError:(BOOL)error;
- (void)presentAlertWithMessage:(NSString *)message;
- (void)showTutorialView;
@end