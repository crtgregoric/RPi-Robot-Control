//
//  CommunicationHelper.h
//  RPi_Control
//
//  Created by Crt Gregoric on 3. 11. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommunicationHelper : NSObject


- (void)sendCommand:(NSString *)command;

@end
