//
//  ChatViewController.m
//  ConcertChat
//
//  Created by Logan O'Connell on 4/5/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "ChatViewController.h"

@implementation ChatViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (appDelegate.manager.session.connectedPeers.count != 0) {
        self.title = [appDelegate.manager.session.connectedPeers[0].displayName componentsSeparatedByString:@":"][0];
    }
    
    else {
        [self endChatFromPeer:self.setupPeerName];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(endChat:)];
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.inputToolbar.contentView.textView.tintColor = UIColorFromRGB(0xF44336);
    self.inputToolbar.contentView.textView.textColor = UIColorFromRGB(0x212121);
    self.inputToolbar.translucent = NO;
    
    [self.inputToolbar.contentView.textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1];
    
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:UIColorFromRGB(0xF44336) forState:UIControlStateNormal];
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:UIColorFromRGB(0xFFCDD2) forState:UIControlStateHighlighted];
    
    self.messages = [NSMutableArray array];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    [self.collectionView addGestureRecognizer:longPress];
    
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.delegate = self;
    self.pickerController.allowsEditing = YES;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapCamera:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self.pickerController.view addGestureRecognizer:doubleTap];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMPCReceivedDataNotification:) name:@"receivedMPCDataNotification" object:nil];
}

- (void)handleMPCReceivedDataNotification:(NSNotification *)notification {
    NSDictionary *receivedDataDictionary = notification.object;
    
    NSData *data = receivedDataDictionary[@"data"];
    MCPeerID *fromPeer = receivedDataDictionary[@"fromPeer"];
    
    NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (dataDictionary[@"message"]) {
        NSString *message = dataDictionary[@"message"];
        
        if (![message isEqualToString:@"_end_chat_"]) {
            NSData *messageImageData;
            if (dataDictionary[@"imageData"]) {
                messageImageData = dataDictionary[@"imageData"];
            }
            
            else {
                messageImageData = [NSData data];
            }
            
            NSDictionary *newMessage = @{@"sender": @"incoming", @"displayName": [fromPeer.displayName componentsSeparatedByString:@":"][0], @"message": message, @"imageData": messageImageData};
            
            [self.messages addObject:newMessage];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                
                [self finishReceivingMessageAnimated:YES];
            }];
        }
        
        else {
            [self endChatFromPeer:[fromPeer.displayName componentsSeparatedByString:@":"][0]];
        }
    }
}

- (void)endChatFromPeer:(NSString *)peerName {
    NSString *message = [NSString stringWithFormat:@"%@ ended this chat.", peerName];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        
        alert.customViewColor = UIColorFromRGB(0xF44336);
        
        alert.statusBarHidden = YES;
        
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
        [alert showInfo:self.tabBarController title:@"" subTitle:message closeButtonTitle:@"OK" duration:0];
        
        [alert alertIsDismissed:^{
            [appDelegate.manager.session disconnect];
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

- (void)endChat:(id)sender {
    if (appDelegate.manager.session.connectedPeers.count != 0) {
        NSDictionary *messageDictionary = @{@"message": @"_end_chat_"};
    
        if ([appDelegate.manager sendData:messageDictionary toPeer:appDelegate.manager.session.connectedPeers[0]]) {
            [appDelegate.manager.session performSelector:@selector(disconnect) withObject:nil afterDelay:0.1];
        
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    else {
        [appDelegate.manager.session performSelector:@selector(disconnect) withObject:nil afterDelay:0.1];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (indexPath) {
        JSQMessagesCollectionViewCell* cell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        if (cell.mediaView) {
            NSDictionary *currentMessage = self.messages[[self.collectionView indexPathForCell:cell].row];
            
            UIImage *image = [UIImage imageWithData:currentMessage[@"imageData"]]
            ;
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
            
            [self presentViewController:activityVC animated:YES completion:nil];
        }
    }
}

- (void)handleImageTap:(UITapGestureRecognizer *)sender {
    if ([self.inputToolbar.contentView.textView isFirstResponder]) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
        [self performSelector:@selector(presentImageViewController:) withObject:sender afterDelay:0.5];
    }
    
    else {
        [self presentImageViewController:sender];
    }
}

- (void)presentImageViewController:(UITapGestureRecognizer *)sender {
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)sender.view;
    
    NSDictionary *currentMessage = self.messages[[self.collectionView indexPathForCell:cell].row];
    
    UIImage *tappedImage = [UIImage imageWithData:currentMessage[@"imageData"]];
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = tappedImage;
    imageInfo.referenceRect = cell.frame;
    imageInfo.referenceView = cell.superview;
    
    JTSImageViewController *imageVC = [[JTSImageViewController alloc] initWithImageInfo:imageInfo mode:JTSImageViewControllerMode_Image backgroundStyle:JTSImageViewControllerBackgroundOption_None];
    
    [imageVC showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)handleImageLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)sender.view;
    
    NSDictionary *currentMessage = self.messages[[self.collectionView indexPathForCell:cell].row];
    
    UIImage *tappedImage = [UIImage imageWithData:currentMessage[@"imageData"]];
    
    NSString *message = @"Save this photo to your Camera Roll?";
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        
    alert.customViewColor = UIColorFromRGB(0xF44336);
        
    alert.statusBarHidden = YES;
        
    [self.inputToolbar.contentView.textView resignFirstResponder];
        
    [alert addButton:@"Yes" actionBlock:^{
        UIImageWriteToSavedPhotosAlbum(tappedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
        
    [alert showQuestion:self.tabBarController title:@"" subTitle:message closeButtonTitle:@"No" duration:0];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.customViewColor = UIColorFromRGB(0xF44336);
    
    alert.statusBarHidden = YES;
    
    [alert showInfo:self.tabBarController title:@"Saved!" subTitle:@"" closeButtonTitle:nil duration:1];
}

// MARK: JSQMessagesCollectionViewCellDelegate
- (void)messagesCollectionViewCellDidTapAvatar:(JSQMessagesCollectionViewCell *)cell {
    return;
}

- (void)messagesCollectionViewCellDidTapMessageBubble:(JSQMessagesCollectionViewCell *)cell {
    return;
}

- (void)messagesCollectionViewCellDidTapCell:(JSQMessagesCollectionViewCell *)cell atPosition:(CGPoint)position {
    return;
}

- (void)messagesCollectionViewCell:(JSQMessagesCollectionViewCell *)cell didPerformAction:(SEL)action withSender:(id)sender {
    return;
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    NSDictionary *messageDictionary = @{@"message": text};
    
    if (appDelegate.manager.session.connectedPeers.count != 0) {
            if ([appDelegate.manager sendData:messageDictionary toPeer:appDelegate.manager.session.connectedPeers[0]]) {
                NSDictionary *newMessage = @{@"sender": self.senderId, @"displayName": [appDelegate.manager.peer.displayName componentsSeparatedByString:@":"][0], @"message": text, @"imageData": [NSData data]};
        
                [self.messages addObject:newMessage];
        
                [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
                [self finishSendingMessageAnimated:YES];
            }
    }
    
    else {
        [self endChatFromPeer:self.title];
    }
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    NSString *message = @"Pick photo from:";
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        
    alert.customViewColor = UIColorFromRGB(0xF44336);
        
    alert.statusBarHidden = YES;
        
    [self.inputToolbar.contentView.textView resignFirstResponder];
        
    [alert addButton:@"Photo Library" actionBlock:^{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentViewController:self.pickerController animated:YES completion:nil];
    }];
        
    [alert addButton:@"Take Photo or Video" actionBlock:^{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        
        [self presentViewController:self.pickerController animated:YES completion:nil];
    }];
        
    [alert showQuestion:self.tabBarController title:@"" subTitle:message closeButtonTitle:@"Cancel" duration:0];
}

- (void)handleDoubleTapCamera:(UITapGestureRecognizer *)sender {
    if (self.pickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    
    else {
        self.pickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

// MARK: JSQMessagesCollectionViewDataSource
- (NSInteger)collectionView:(JSQMessagesCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    NSDictionary *currentMessage = self.messages[indexPath.row];
    
    if (![currentMessage[@"sender"] isEqualToString:[userDefaults objectForKey:@"uuid"]]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    
    if (((NSData *)currentMessage[@"imageData"]).length != 0) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
        tap.delegate = self;
        [cell addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageLongPress:)];
        longPress.delegate = self;
        [cell addGestureRecognizer:longPress];
    }
    
    return cell;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath; {
    NSDictionary *currentMessage = self.messages[indexPath.row];
    
    NSData *imageData = currentMessage[@"imageData"];
    
    if (imageData.length != 0) {
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
        
        return [JSQMessage messageWithSenderId:currentMessage[@"sender"] displayName:currentMessage[@"displayName"] media:mediaItem];
    }
    
    return [JSQMessage messageWithSenderId:currentMessage[@"sender"] displayName:currentMessage[@"displayName"] text:currentMessage[@"message"]];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    [self.messages removeObjectAtIndex:indexPath.row];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    NSDictionary *currentMessage = self.messages[indexPath.row];
    
    if ([currentMessage[@"sender"] isEqualToString:[userDefaults objectForKey:@"uuid"]]) {
        return [factory outgoingMessagesBubbleImageWithColor:UIColorFromRGB(0xF44336)]
        ;
    }
    
    return [factory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger counter = 0;
    NSInteger lastIndexRowNumber = -1;
    for (NSDictionary *currentMessage in [self.messages reverseObjectEnumerator]) {
        if ([currentMessage[@"sender"] isEqualToString:[userDefaults objectForKey:@"uuid"]]) {
            lastIndexRowNumber = self.messages.count - counter - 1;
            
            break;
        }
        
        counter++;
    }
    
    if (indexPath.row == lastIndexRowNumber) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger counter = 0;
    NSInteger lastIndexRowNumber = -1;
    for (NSDictionary *currentMessage in [self.messages reverseObjectEnumerator]) {
        if ([currentMessage[@"sender"] isEqualToString:[userDefaults objectForKey:@"uuid"]]) {
            lastIndexRowNumber = self.messages.count - counter - 1;
            
            break;
        }
        
        counter++;
    }
    
    if (indexPath.row == lastIndexRowNumber) {
        return [[NSAttributedString alloc] initWithString
                :@"Sent" attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x212121)}];
    }
    
    return nil;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

// MARK: UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    NSDictionary *messageDictionary = @{@"message": @"", @"imageData": UIImagePNGRepresentation(chosenImage)};
    
    if (appDelegate.manager.session.connectedPeers.count != 0) {
        if ([appDelegate.manager sendData:messageDictionary toPeer:appDelegate.manager.session.connectedPeers[0]]) {
            NSDictionary *newMessage = @{@"sender": self.senderId, @"displayName": [appDelegate.manager.peer.displayName componentsSeparatedByString:@":"][0], @"message": @"", @"imageData": UIImagePNGRepresentation(chosenImage)};
        
            [self.messages addObject:newMessage];
        
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
            [self finishSendingMessageAnimated:YES];
        }
    }
    
    else {
        [self endChatFromPeer:self.title];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: JSQMessagesComposerTextViewPasteDelegate
- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender {
    if ([UIPasteboard generalPasteboard].image) {
        UIImage *pastedImage = [UIPasteboard generalPasteboard].image;
        
        NSDictionary *messageDictionary = @{@"message": @"", @"imageData": UIImagePNGRepresentation(pastedImage)};
        
        if (appDelegate.manager.session.connectedPeers.count != 0) {
            if ([appDelegate.manager sendData:messageDictionary toPeer:appDelegate.manager.session.connectedPeers[0]]) {
                NSDictionary *newMessage = @{@"sender": self.senderId, @"displayName": [appDelegate.manager.peer.displayName componentsSeparatedByString:@":"][0], @"message": @"", @"imageData": UIImagePNGRepresentation(pastedImage)};
            
                [self.messages addObject:newMessage];
            
                [JSQSystemSoundPlayer jsq_playMessageSentSound];
            
                [self finishSendingMessageAnimated:YES];
            }
        }
        
        else {
            [self endChatFromPeer:self.title];
        }
        
        return NO;
    }
    
    return YES;
}
@end