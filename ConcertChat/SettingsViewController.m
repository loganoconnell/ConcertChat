//
//  SettingsViewController.m
//  ConcertChat
//
//  Created by Logan O'Connell on 4/6/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
- (void)viewDidLoad {
    self.title = @"Settings";
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Change nickname";
                
                break;
            default:
                break;
        }
    }
    
    else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Email support";
                
                break;
            case 1:
                cell.textLabel.text = @"Follow @logandev22";
                
                break;
            case 2:
                cell.textLabel.text = @"View app on Github";
                
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)showChangeNicknameAlert {
    [(ViewController *)((UINavigationController *)self.tabBarController.viewControllers.firstObject).viewControllers.firstObject askForNicknameWithError:NO];
}

// MARK: UITableViewDelegate/UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self showChangeNicknameAlert];
        }
    }
    
    else {
        switch (indexPath.row) {
            case 0:
                if ([MFMailComposeViewController canSendMail] ) {
                    MFMailComposeViewController *composeVC = [[MFMailComposeViewController alloc] init];
                    composeVC.mailComposeDelegate = self;
                    [composeVC setToRecipients:@[@"logan.developeremail@gmail.com"]];
                    [composeVC setSubject:@"\"ConcertChat\" Support"];
                    
                    [self presentViewController:composeVC animated:YES completion:nil];
                }
                
                break;
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/logandev22"]];
                
                break;
            case 2:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/loganoconnell/concertchat"]];
                
                break;
            default:
                break;
        }
        
        
    }
    
    [self.settingsTableView cellForRowAtIndexPath:indexPath].selected = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerFooterView = ((UITableViewHeaderFooterView *)view);
    headerFooterView.textLabel.textAlignment = NSTextAlignmentCenter;
    headerFooterView.textLabel.textColor = UIColorFromRGB(0x212121);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    else if (section == 1) {
        return 3;
    }
    
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"idSettingsCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idSettingsCell"];
    }
    
    cell.textLabel.textColor = UIColorFromRGB(0xF44336);
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Nickname";
    }
    
    else if (section == 1) {
        return @"Information";
    }
    
    else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"© 2016 Logan O'Connell";
    }
    
    return nil;
}

// MARK: MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end