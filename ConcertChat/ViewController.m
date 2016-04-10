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
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    if (![userDefaults objectForKey:@"nickname"]) {
        [self askForNicknameWithError:NO];
    }
    
    else {
        [self startUpManager];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];
    
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
        }];
        
        [alert showEdit:self.tabBarController title:title subTitle:message closeButtonTitle:@"Cancel" duration:0];
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
        }];
    }
}

- (void)askForConcertName {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.customViewColor = UIColorFromRGB(0xF44336);
    
    alert.statusBarHidden = YES;
    
    UITextField *textField = [alert addTextField:@"Concert name"];
    textField.placeholder = @"Concert name";
    
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
    }];
    
    [alert showEdit:self.tabBarController title:@"Share Concert" subTitle:@"Please enter the concert/artist name." closeButtonTitle:@"Cancel" duration:0];
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
    }
}

// MARK UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)theTabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (self != self.navigationController.visibleViewController) {
        return NO;
    }
    
    return YES;
}

// MARK UITableViewDelegate/UITableViewDataSource
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
    
    if ([MBProgressHUD HUDForView:self.view]) {
        [[MBProgressHUD HUDForView:self.view] show:YES];
    }
    
    else {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Connecting...";
    }
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
            
            if ([MBProgressHUD HUDForView:self.view]) {
                [[MBProgressHUD HUDForView:self.view] show:YES];
            }
            
            else {
                self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self.hud.labelText = @"Connecting...";
            }
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
            
        for (MBProgressHUD *hud in [MBProgressHUD allHUDsForView:self.view]) {
            [hud hide:YES];
        }
        
        [self performSegueWithIdentifier:@"idChatSegue" sender:self];
    }];
}

- (void)failedToConnectWithPeer:(MCPeerID *)peerID {
    if (self == self.navigationController.visibleViewController) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.peersTableView cellForRowAtIndexPath:self.selectedCellIndex].selected = NO;
            
            for (MBProgressHUD *hud in [MBProgressHUD allHUDsForView:self.view]) {
                [hud hide:YES];
            }
            
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([searchBar.text isEqualToString:@""]) {
        self.isSearching = NO;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

-  (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
@end