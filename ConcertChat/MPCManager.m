//
//  MPCManager.m
//  ConcertChat
//
//  Created by Logan O'Connell on 4/4/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

#import "MPCManager.h"

@implementation MPCManager
- (instancetype)initWithNickname:(NSString *)nickname {
    if (self = [super init]) {
        NSString *peerName = [NSString stringWithFormat:@"%@:%@", nickname, [[UIDevice currentDevice] name]];
        self.peer = [[MCPeerID alloc] initWithDisplayName:peerName];
        
        self.session = [[MCSession alloc] initWithPeer:self.peer];
        self.session.delegate = self;
        
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peer serviceType:@"concertchat-mpc"];
        self.browser.delegate = self;
        
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peer discoveryInfo:nil serviceType:@"concertchat-mpc"];
        self.advertiser.delegate = self;
        
        self.foundPeers = [NSMutableArray array];
        
        if (![userDefaults objectForKey:@"uuid"]) {
            [userDefaults setObject:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        }
    }
    
    return self;
}

- (BOOL)sendData:(NSDictionary *)dictionaryWithData toPeer:(MCPeerID *)targetPeer {
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:dictionaryWithData];
    NSArray *peersArray = [NSArray arrayWithObjects:targetPeer, nil];
    
    NSError *error;
    
    [self.session sendData:dataToSend toPeers:peersArray withMode:MCSessionSendDataReliable error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        
        return NO;
    }
    
    return YES;
}

// MARK: MCSessionDelegate
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"Connected to session: %@", session);
            
            [self.delegate connectedWithPeer:peerID];
            
            self.isConnected = YES;
            
            break;
        case MCSessionStateConnecting:
            NSLog(@"Connecting to session: %@", session);
            
            break;
            
        case MCSessionStateNotConnected:
            NSLog(@"Did not connect to session: %@", session);
            
            if (!self.isConnected) {
                [self.delegate failedToConnectWithPeer:peerID];
            }
            
            self.isConnected = NO;
            
            break;
            
        default:
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *dictionary = @{@"data": data, @"fromPeer": peerID};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMPCDataNotification" object:dictionary];
    
    NSLog(@"%@", dictionary);
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    return;
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    return;
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    return;
}

// MARK: MCNearbyServiceBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    for (MCPeerID *aPeer in self.foundPeers) {
        if ([aPeer.displayName isEqualToString:peerID.displayName]) {
            [self.foundPeers replaceObjectAtIndex:[self.foundPeers indexOfObject:aPeer] withObject:peerID];
            
            [self.delegate foundPeer];
            
            return;
        }
    }
    
    [self.foundPeers addObject:peerID];
    
    [self.delegate foundPeer];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSUInteger index = 0;
    
    for (MCPeerID *aPeer in self.foundPeers) {
        if ([aPeer.displayName isEqualToString:peerID.displayName]) {
            [self.foundPeers removeObjectAtIndex:index];
            
            break;
        }
        
        index++;
    }
    
    [self.delegate lostPeer];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    [self.delegate failedToStartBrowsing:error.localizedDescription];
}

// MARK: MCNearbyServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    self.invitationHandler = invitationHandler;
    
    [self.delegate invitationWasRecieved:peerID.displayName];
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    [self.delegate failedToStartAdvertising:error.localizedDescription];
}
@end