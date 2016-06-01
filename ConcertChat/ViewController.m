//
//  ViewController.m
//  ConcertChat
//
//  Created by Logan O'Connell on 4/4/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Chat";
    
    self.tabBarController.tabBar.tintColor = UIColorFromRGB(0x212121);
    self.tabBarController.delegate = self;
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setBackgroundColor:UIColorFromRGB(0x212121)];
    
    self.noDataView = [[UIView alloc] initWithFrame:self.peersTableView.frame];
    [self setupNoDataView];
    
    self.peersTableView.nxEV_emptyView = self.noDataView;
    self.peersTableView.tableFooterView = [UIView new];

    self.extendedLayoutIncludesOpaqueBars = YES;
    
    DGElasticPullToRefreshLoadingViewCircle* loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = self.peersTableView.backgroundColor;
    
    [self.peersTableView dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:50 loadingViewSize:30 actionHandler:^{
        [self startUpManager];
        
        [self.peersTableView dg_stopLoading];
    } loadingView:loadingView];
    
    [self.peersTableView dg_setPullToRefreshFillColor:UIColorFromRGB(0x212121)];
    
    [self.peersTableView dg_setPullToRefreshBackgroundColor:self.peersTableView.backgroundColor];
    
    if (![userDefaults objectForKey:@"nickname"]) {
        [self showTutorialView];
    }
    
    else {
        [self startUpManager];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.noDataImage.hidden = YES;
        
        self.noDataLabel.frame = CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - 100) / 2 - 88, [UIScreen mainScreen].bounds.size.width, 100);
    }
    
    else {
        self.noDataImage.hidden = NO;
        
        self.noDataLabel.frame = CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - 200) / 2 - 8, [UIScreen mainScreen].bounds.size.width, 100);
    }
}

- (void)showTutorialView {
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.isTutorialInLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat titleY;
    CGFloat descY;
    CGFloat titleIconY;
    
    if (self.isTutorialInLandscape) {
        titleY = screenHeight - 135;
        descY = screenHeight - 155;
        titleIconY = 35;
    }
    
    else {
        titleY = screenHeight - 175;
        descY = screenHeight - 195;
        titleIconY = 75;
    }
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Welcome to ConcertChat";
    page1.titlePositionY = titleY;
    page1.titleFont = [UIFont boldSystemFontOfSize:20];
    page1.desc = @"Are you ready to party? Let's teach you how to get started!";
    page1.descPositionY = descY;
    page1.descFont = [UIFont systemFontOfSize:15];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ConcertChat"]];
    CGRect alteredFrame1 = page1.titleIconView.frame;
    alteredFrame1.size.width = 50;
    alteredFrame1.size.height = 50;
    page1.titleIconView.frame = alteredFrame1;
    page1.titleIconPositionY = titleIconY;
    page1.bgImage = [UIImage imageNamed:@"Concert1.jpg"];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"How to Start";
    page2.titlePositionY = titleY;
    page2.titleFont = [UIFont boldSystemFontOfSize:20];
    page2.desc = @"Once this tutorial is finished, you will be presented with a list of available devices around you. Touch a device and you will attempt to connect with it.";
    page2.descPositionY = descY;
    page2.descFont = [UIFont systemFontOfSize:15];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ConcertChat"]];
    CGRect alteredFrame2 = page2.titleIconView.frame;
    alteredFrame2.size.width = 50;
    alteredFrame2.size.height = 50;
    page2.titleIconView.frame = alteredFrame2;
    page2.titleIconPositionY = titleIconY;
    page2.bgImage = [UIImage imageNamed:@"Concert2.jpg"];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"How to Chat";
    page3.titlePositionY = titleY;
    page3.titleFont = [UIFont boldSystemFontOfSize:20];
    page3.desc = @"Once your device connects to another, you can chat with the person you connected with, and go find them to party with!";
    page3.descPositionY = descY;
    page3.descFont = [UIFont systemFontOfSize:15];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ConcertChat"]];
    CGRect alteredFrame3 = page3.titleIconView.frame;
    alteredFrame3.size.width = 50;
    alteredFrame3.size.height = 50;
    page3.titleIconView.frame = alteredFrame3;
    page3.titleIconPositionY = titleIconY;
    page3.bgImage = [UIImage imageNamed:@"Concert3.jpg"];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"That's it!";
    page4.titlePositionY = titleY;
    page4.titleFont = [UIFont boldSystemFontOfSize:20];
    page4.desc = @"Now go get partying!";
    page4.descPositionY = descY;
    page4.descFont = [UIFont systemFontOfSize:15];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ConcertChat"]];
    CGRect alteredFrame4 = page4.titleIconView.frame;
    alteredFrame4.size.width = 50;
    alteredFrame4.size.height = 50;
    page4.titleIconView.frame = alteredFrame4;
    page4.titleIconPositionY = titleIconY;
    page4.bgImage = [UIImage imageNamed:@"Concert4.jpg"];
    page4.onPageDidAppear = ^{
        intro.skipButton.hidden = YES;
    };
    page4.onPageDidDisappear = ^{
        intro.skipButton.hidden = NO;
    };
    
    intro.pages = @[page1, page2, page3, page4];
    intro.delegate = self;
    [intro showInView:self.tabBarController.view];
    
    self.isShowingTutorial = YES;
}

- (void)setupNoDataView {
    self.noDataView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    self.noDataView.center = self.peersTableView.center;
    
    self.noDataImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppIcon60x60"]];
    self.noDataImage.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) / 2, ([UIScreen mainScreen].bounds.size.height - 200) / 2 - 108, 100, 100);
    [self.noDataView addSubview:self.noDataImage];
    
    self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - 200) / 2 - 8, [UIScreen mainScreen].bounds.size.width, 100)];
    self.noDataLabel.text = @"No devices found :(";
    self.noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.noDataLabel.font = [UIFont italicSystemFontOfSize:18
                             ];
    self.noDataLabel.textColor = UIColorFromRGB(0xB6B6B6);
    [self.noDataView addSubview:self.noDataLabel];
}

- (void)askForNicknameWithError:(BOOL)error {
    NSString *title = error ? @"Error" : @"Nickname";
    NSString *message = error ? @"Please enter a valid nickname." : @"Please enter a nickname.";
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.customViewColor = UIColorFromRGB(0xF44336);
    
    alert.statusBarHidden = YES;
    
    UITextField *textField = [alert addTextField:@"Nickname"];
    textField.placeholder = @"Nickname";
    
    textField.tintColor = UIColorFromRGB(0xF44336);
    
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    
    if ([userDefaults objectForKey:@"nickname"]) {
        [alert addButton:@"OK" actionBlock:^{
            NSString *text = textField.text;
            
            if ([text isEqualToString:@""]) {
                [self askForNicknameWithError:YES];
            }
            
            else {
                [userDefaults setObject:text forKey:@"nickname"];
                
                [self startUpManager];
            }
            
            [textField resignFirstResponder];
        }];
        
        [alert addButton:@"Cancel" actionBlock:^{
            [textField resignFirstResponder];
        }];
        
        [alert showEdit:self.tabBarController title:title subTitle:message closeButtonTitle:nil duration:0];
    }
    
    else {
        [alert showEdit:self.tabBarController title:title subTitle:message closeButtonTitle:@"OK" duration:0];
        
        [alert alertIsDismissed:^{
            NSString *text = textField.text;
            
            if ([text isEqualToString:@""]) {
                [self askForNicknameWithError:YES];
            }
            
            else {
                [userDefaults setObject:text forKey:@"nickname"];
                
                [self startUpManager];
            }
            
            [textField resignFirstResponder];
        }];
    }
}

- (void)askForConcertName {
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
        
        if ([text isEqualToString:@""]) {
            [self askForConcertName];
        }
        
        else {
            [self _shareConcertWithName:text];
        }
        
        [textField resignFirstResponder];
    }];
    
    [alert addButton:@"Cancel" actionBlock:^{
        [textField resignFirstResponder];
    }];
    
    [alert showEdit:self.tabBarController title:@"Share Concert" subTitle:@"Please enter the concert/artist name." closeButtonTitle:nil duration:0];
}

- (void)_shareConcertWithName:(NSString *)name {
    NSString *stringToShare = [NSString stringWithFormat:@"I'm using the iOS app ConcertChat at the %@ concert to connect with people nearby and find someone to party with!", name];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[stringToShare] applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)presentAlertWithMessage:(NSString *)message {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.customViewColor = UIColorFromRGB(0xF44336);
    
    alert.statusBarHidden = YES;
    
    [alert showInfo:self.tabBarController title:@"" subTitle:message closeButtonTitle:@"OK" duration:0];
}

- (void)startUpManager {
    appDelegate.manager = [[MPCManager alloc] initWithNickname:[userDefaults objectForKey:@"nickname"]];
    
    appDelegate.manager.delegate = self;
    
    [appDelegate.manager.browser startBrowsingForPeers];
    
    [appDelegate.manager.advertiser startAdvertisingPeer];
    
    self.isAdvertising = YES;
}

- (IBAction)shareConcert:(id)sender {
    [self askForConcertName];
}

- (IBAction)startStopAdvertising:(id)sender {
    if (self.isAdvertising) {
        [appDelegate.manager.advertiser stopAdvertisingPeer];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Invisible"] style:UIBarButtonItemStylePlain target:self action:@selector(startStopAdvertising:)];
    }
    
    else {
        [appDelegate.manager.advertiser startAdvertisingPeer];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Visible"] style:UIBarButtonItemStylePlain target:self action:@selector(startStopAdvertising:)];
    }
    
    self.isAdvertising = !self.isAdvertising;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"idChatSegue"]) {
        ChatViewController *chatVC =  (ChatViewController *)segue.destinationViewController;
        chatVC.setupPeerName = self.connectedPeerName;
        chatVC.senderDisplayName = [userDefaults objectForKey:@"nickname"];
        chatVC.senderId = [userDefaults objectForKey:@"uuid"];
        
        self.hidesBottomBarWhenPushed = YES;
        
        [self performSelector:@selector(setHidesBottomBarWhenPushed:) withObject:@NO afterDelay:0.1];
    }
}

// MARK: UITabBarControllerDelegate
- (UIInterfaceOrientationMask)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController {
    if (self.isShowingTutorial) {
        if (self.isTutorialInLandscape) {
            return UIInterfaceOrientationMaskLandscape;
        }
        
        else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }

    else if (self.isSearching) {
        if (self.isSearchInLandscape) {
            return UIInterfaceOrientationMaskLandscape;
        }
        
        else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
    
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

// MARK: UITableViewDelegate/UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchResults.count;
    }
    
    return appDelegate.manager.foundPeers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"idPeerCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"idPeerCell"];
    }
    
    NSString *text;
    if (self.isSearching) {
        text = self.searchResults[indexPath.row].displayName;
    }
    
    else {
        text = appDelegate.manager.foundPeers[indexPath.row].displayName;
    }
    
    cell.textLabel.text = [text componentsSeparatedByString:@":"][0];
    cell.detailTextLabel.text = [text componentsSeparatedByString:@":"][1];
    cell.imageView.image = [UIImage imageNamed:@"Phone"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPeerID *selectedPeer;

    if (self.isSearching) {
        selectedPeer = self.searchResults[indexPath.row];
    }
    
    else {
        selectedPeer = appDelegate.manager.foundPeers[indexPath.row];
    }
    
    [appDelegate.manager.browser invitePeer:selectedPeer toSession:appDelegate.manager.session withContext:nil timeout:15];
    
    self.selectedCellIndex = indexPath;
    
    [SVProgressHUD showWithStatus:@"Connecting..."];
}

// MARK: MPCManagerDelegate
- (void)foundPeer {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.peersTableView reloadData];
    }];
    
}

- (void)lostPeer {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.peersTableView reloadData];
    
        if (self != self.navigationController.visibleViewController) {
            ChatViewController *chatVC = (ChatViewController *)self.navigationController.visibleViewController;
            [chatVC endChatFromPeer:chatVC.title];
        }
    }];
}

- (void)invitationWasRecieved:(NSString *)fromPeer {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (self.isSearching) {
            [self.searchBar resignFirstResponder];
        }
        
        NSString *message = [NSString stringWithFormat:@"%@ wants to chat with you.", [fromPeer componentsSeparatedByString:@":"][0]];
    
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        
        alert.customViewColor = UIColorFromRGB(0xF44336);
        
        alert.statusBarHidden = YES;
    
        [alert addButton:@"Accept" actionBlock:^{
            if (self != self.navigationController.visibleViewController) {
                ChatViewController *chatVC = (ChatViewController *)self.navigationController.visibleViewController;
                [chatVC endChat:nil];
            }
            
            appDelegate.manager.invitationHandler(YES, appDelegate.manager.session);
            
            [SVProgressHUD showWithStatus:@"Connecting..."];
        }];
        
        [alert addButton:@"Decline" actionBlock:^{
            appDelegate.manager.invitationHandler(NO, appDelegate.manager.session);
        }];
    
        [alert showQuestion:self.tabBarController title:@"" subTitle:message closeButtonTitle:nil duration:0];
    }];
}

- (void)connectedWithPeer:(MCPeerID *)peerID {
    self.connectedPeerName = [peerID.displayName componentsSeparatedByString:@":"][0];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.peersTableView cellForRowAtIndexPath:self.selectedCellIndex].selected = NO;
            
        [SVProgressHUD dismiss];
        
        [self performSegueWithIdentifier:@"idChatSegue" sender:self];
    }];
}

- (void)failedToConnectWithPeer:(MCPeerID *)peerID {
    if (self == self.navigationController.visibleViewController) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.peersTableView cellForRowAtIndexPath:self.selectedCellIndex].selected = NO;
            
            [SVProgressHUD dismiss];
            
            [self presentAlertWithMessage:[NSString stringWithFormat:@"Failed to connect with %@.", [peerID.displayName componentsSeparatedByString:@":"][0]]];
        }];
    }
}

- (void)failedToStartBrowsing:(NSString *)error {
    [self presentAlertWithMessage:[NSString stringWithFormat:@"Failed to start browsing for peers with error: %@.", error]];
}

- (void)failedToStartAdvertising:(NSString *)error {
    [self presentAlertWithMessage:[NSString stringWithFormat:@"Failed to start advertising peer with error: %@.", error]];
}

// MARK: UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
    
    self.isSearchInLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if (self.isSearchInLandscape) {
        self.tableViewVerticalLandscapeConstraint.constant = 0;
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([searchBar.text isEqualToString:@""]) {
        self.isSearching = NO;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.tableViewVerticalLandscapeConstraint.constant = -32;
    }
}

-  (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.tableViewVerticalLandscapeConstraint.constant = -32;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchResults = [NSMutableArray array];
    
    for (MCPeerID *peer in appDelegate.manager.foundPeers) {
        if ([[[peer.displayName componentsSeparatedByString:@":"][0] lowercaseString] containsString:[searchText lowercaseString]]) {
            [self.searchResults addObject:peer];
        }
    }
    
    for (MCPeerID *peer in appDelegate.manager.foundPeers) {
        if ([[[peer.displayName componentsSeparatedByString:@":"][1] lowercaseString] containsString:[searchText lowercaseString]] && ![self.searchResults containsObject:peer]) {
            [self.searchResults addObject:peer];
        }
    }
}

// MARK: EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView {
    if (![userDefaults objectForKey:@"nickname"]) {
        [self askForNicknameWithError:NO];
    }
    
    self.isShowingTutorial = NO;
}
@end