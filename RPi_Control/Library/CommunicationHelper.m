//
//  CommunicationHelper.m
//  RPi_Control
//
//  Created by Crt Gregoric on 3. 11. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "CommunicationHelper.h"

@interface CommunicationHelper () <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation CommunicationHelper

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    
    if (self) {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)kHostName, kPortNumber, &readStream, &writeStream);
        
        self.inputStream = (__bridge NSInputStream *)readStream;
        self.outputStream = (__bridge NSOutputStream *)writeStream;
        
        self.inputStream.delegate = self;
        self.outputStream.delegate = self;
        
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self.inputStream open];
        [self.outputStream open];
    }
    
    return self;
}

#pragma mark - Sending and receiving messages

- (void)sendMessage:(NSString *)message {
    NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)receiveDataFromInputStream:(NSInputStream *)stream {
    uint8_t buffer[256];
    NSInteger len = 0;
    NSMutableData *data = [[NSMutableData alloc] init];
    
    while (stream.hasBytesAvailable) {
        len = [stream read:buffer maxLength:sizeof(buffer)];
        
        if (len) {
            [data appendBytes:(const void *)buffer length:len];
        }
    }
    
    NSString *message = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if (message) {
        NSLog(@"received message: %@", message);
        
        if ([self.delegate respondsToSelector:@selector(communicationHelper:didReceiveMessage:)]) {
            [self.delegate communicationHelper:self didReceiveMessage:message];
        }
    }
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    NSString *streamString = [stream isKindOfClass:[NSInputStream class]] ? @"inputStream" : @"outputStream";
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"%@: NSStreamEventOpenCompleted", streamString);
            
            if ([self.delegate respondsToSelector:@selector(communicationHelperDidConnectToHost:)]) {
                [self.delegate communicationHelperDidConnectToHost:self];
            }
            
            break;
            
        case NSStreamEventHasBytesAvailable:
//            NSLog(@"%@: NSStreamEventHasBytesAvailable", streamString);
            
            if ([stream isKindOfClass:[NSInputStream class]]) {
                [self receiveDataFromInputStream:(NSInputStream *)stream];
            }
            
            break;
            
        case NSStreamEventHasSpaceAvailable:
//            NSLog(@"%@: NSStreamEventHasSpaceAvailable", streamString);
            break;
        
        case NSStreamEventEndEncountered:
            NSLog(@"%@: NSStreamEventEndEncountered", streamString);
            
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            if ([self.delegate respondsToSelector:@selector(communicationHelperDidDisconnectFromHost:)]) {
                [self.delegate communicationHelperDidDisconnectFromHost:self];
            }
            
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"%@: NSStreamEventErrorOccurred: %@", streamString, stream.streamError);
            
            if ([self.delegate respondsToSelector:@selector(communicationHelper:encounteredAnError:)]) {
                [self.delegate communicationHelper:self encounteredAnError:stream.streamError];
            }
            
            break;
            
        case NSStreamEventNone:
            NSLog(@"%@: NSStreamEventNone", streamString);
            break;
    }
}

@end
