//
//  CommunicationHelper.h
//  RPi_Control
//
//  Created by Crt Gregoric on 3. 11. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommunicationHelper;

@protocol CommunicationHelperDelegate <NSObject>

- (void)communicationHelperDidConnectToHost:(CommunicationHelper *)helper;
- (void)communicationHelperDidDisconnectFromHost:(CommunicationHelper *)helper;
- (void)communicationHelper:(CommunicationHelper *)helper encounteredAnError:(NSError *)error;

- (void)communicationHelper:(CommunicationHelper *)helper didReceiveMessage:(NSString *)message;

@end

@interface CommunicationHelper : NSObject

@property (nonatomic, weak) id<CommunicationHelperDelegate> delegate;

- (void)sendMessage:(NSString *)message;

@end
