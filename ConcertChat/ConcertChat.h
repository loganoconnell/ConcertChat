//
//  ConcertChat.h
//  ConcertChat
//
//  Created by Logan O'Connell on 4/4/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#ifndef ConcertChat_h
#define ConcertChat_h

#define PRODUCTION_MODE 0

#if PRODUCTION_MODE
    #define NSLog(...)
#endif

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define userDefaults [NSUserDefaults standardUserDefaults]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255 green:((float)((rgbValue & 0xFF00) >> 8))/255 blue:((float)(rgbValue & 0xFF))/255 alpha:1]

@import Foundation;
@import UIKit;
@import MultipeerConnectivity;
@import MessageUI;
@import CoreLocation;

#import "DGElasticPullToRefresh/DGElasticPullToRefresh.h"

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesViewController/JSQMessagesComposerTextView.h>
#import <JSQMessagesViewController/JSQPhotoMediaItem.h>
#import <JSQMessagesViewController/JSQSystemSoundPlayer+JSQMessages.h>
#import <JSQMessagesViewController/UIColor+JSQMessages.h>

#import <SCLAlertView-Objective-C/SCLAlertView.h>

#import <SVProgressHUD/SVProgressHUD.h>

#import <JTSImageViewController/JTSImageViewController.h>

#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>

#import <EAIntroView/EAIntroView.h>

#import <CMPopTipView/CMPopTipView.h>

#import <BFPaperTableViewCell/BFPaperTableViewCell.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <TwitterKit/TwitterKit.h>

#endif /* ConcertChat_h */