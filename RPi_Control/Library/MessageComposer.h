//
//  MessageComposer.h
//  RPi_Control
//
//  Created by Crt Gregoric on 11. 12. 14.
//  Copyright (c) 2014 crtgregoric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MessageComposer : NSObject

+ (NSString *)messageWithCommandType:(int)type cameraTilt:(CGFloat)tilt;
+ (NSString *)messageWithCommandType:(int)type position:(CGPoint)position;

#pragma mark - Led messages

+ (NSString *)allLedOffMessageWithCommandType:(int)type;
+ (NSString *)messageWithCommandType:(int)type ledOnForState:(int)state;
+ (NSString *)messageWithCommandType:(int)type ledBrightness:(CGFloat)brightness ledState:(int)state;

+ (NSString *)shutdownMessage;

@end
