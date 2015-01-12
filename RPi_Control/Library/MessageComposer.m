//
//  MessageComposer.m
//  RPi_Control
//
//  Created by Crt Gregoric on 11. 12. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "MessageComposer.h"

@implementation MessageComposer

+ (NSString *)basicMessageWithCommandType:(int)type firstArg:(int)first secondArg:(int)second {
    return [NSString stringWithFormat:@"%d %d %d|", type, first, second];
}

+ (NSString *)messageWithCommandType:(int)type cameraTilt:(CGFloat)tilt {
    return [self basicMessageWithCommandType:type firstArg:0 secondArg:(int)(tilt * 100)];
}

+ (NSString *)messageWithCommandType:(int)type position:(CGPoint)position {
    return [self basicMessageWithCommandType:type firstArg:(int)(position.x * 100) secondArg:(int)(position.y * 100)];
}

#pragma mark - Led messages

+ (NSString *)allLedOffMessageWithCommandType:(int)type {
    return [self basicMessageWithCommandType:type firstArg:0 secondArg:0];
}

+ (NSString *)messageWithCommandType:(int)type ledOnForState:(int)state {
    return [self basicMessageWithCommandType:type firstArg:100 secondArg:state];
}

+ (NSString *)messageWithCommandType:(int)type ledBrightness:(CGFloat)brightness ledState:(int)state {
    return [self basicMessageWithCommandType:type firstArg:(int)(brightness * 100) secondArg:state];
}

+ (NSString *)shutdownMessage
{
    return [self basicMessageWithCommandType:3 firstArg:0 secondArg:0];
}

@end
