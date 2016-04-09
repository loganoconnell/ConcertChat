//
//  MPCManager.h
//  ConcertChat
//
//  Created by Logan O'Connell on 4/4/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "ConcertChat.h"

@protocol MPCManagerDelegate <NSObject>
- (void)foundPeer;
- (void)lostPeer;
- (void)invitationWasRecieved:(NSString *)fromPeer;
- (void)connectedWithPeer:(MCPeerID *)peerID;
- (void)failedToConnectWithPeer:(MCPeerID *)peerID;
- (void)failedToStartBrowsing:(NSString *)error;
- (void)failedToStartAdvertising:(NSString *)error;
@end

@interface MPCManager : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *peer;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) NSMutableArray<MCPeerID *> *foundPeers;
@property (nonatomic, strong) void (^invitationHandler)(BOOL, MCSession *);

@property (nonatomic, strong) id<MPCManagerDelegate> delegate;

@property (nonatomic) BOOL isConnected;

- (instancetype)initWithNickname:(NSString *)nickname;
- (BOOL)sendData:(NSDictionary *)dictionaryWithData toPeer:(MCPeerID *)targetPeer;
@end