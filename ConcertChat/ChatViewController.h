//
//  ChatViewController.h
//  ConcertChat
//
//  Created by Logan O'Connell on 4/5/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "ConcertChat.h"

#import "AppDelegate.h"

@interface ChatViewController : JSQMessagesViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate,JSQMessagesCollectionViewCellDelegate, JSQMessagesCollectionViewDelegateFlowLayout, JSQMessagesCollectionViewDataSource, JSQMessagesComposerTextViewPasteDelegate>
@property (nonatomic, strong) UIImagePickerController *pickerController;

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSString *setupPeerName;

- (void)endChatFromPeer:(NSString *)peerName;
@end