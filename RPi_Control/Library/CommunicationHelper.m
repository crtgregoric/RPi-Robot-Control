//
//  CommunicationHelper.m
//  RPi_Control
//
//  Created by Crt Gregoric on 3. 11. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "CommunicationHelper.h"

static const NSTimeInterval kReconnectInterval = 5.0;
static const NSUInteger kBufferSize = 256;

@interface CommunicationHelper () <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) NSTimer *reconnectTimer;
@property (nonatomic, strong) NSTimer *checkStatusTimer;

@end

@implementation CommunicationHelper

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self connect];
        self.checkStatusTimer = [NSTimer scheduledTimerWithTimeInterval:kReconnectInterval target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)connect {
    NSLog(@"CommunicationHelper: connect");
    
    [self closeStream:self.inputStream];
    [self closeStream:self.outputStream];
    
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)kHostName, kPortNumber, &readStream, &writeStream);
    
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    [self.inputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [self.outputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;

    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}

#pragma mark - Helper methods

- (void)startReconnecting {
    if (!self.reconnectTimer.isValid) {
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:kReconnectInterval target:self selector:@selector(connect) userInfo:nil repeats:YES];
        
        [self.checkStatusTimer invalidate];
    }
}

- (void)stopReconnectiong {
    [self.reconnectTimer invalidate];
    [self.checkStatusTimer invalidate];
}

- (void)closeStream:(NSStream *)stream {
    [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    stream.delegate = nil;
    [stream close];
    stream = nil;
}

- (void)checkStatus {
    if (self.outputStream.streamStatus == NSStreamStatusOpening) {
        if ([self.delegate respondsToSelector:@selector(communicationHelper:encounteredAnError:)]) {
            NSError *error = [NSError errorWithDomain:@"error" code:404 userInfo:@{ NSLocalizedDescriptionKey : @"Host not found." }];
            [self.delegate communicationHelper:self encounteredAnError:error];
        }
        
        [self connect];
        
    } else {
        [self.checkStatusTimer invalidate];
    }
}

#pragma mark - Sending and receiving messages

- (void)sendMessage:(NSString *)message {
    if (message && self.outputStream.streamStatus == NSStreamStatusOpen) {
        NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
        [self.outputStream write:data.bytes maxLength:data.length];
    }
}

- (void)receiveDataFromInputStream:(NSInputStream *)stream {
    uint8_t buffer[kBufferSize];
    NSInteger len = 0;
    NSMutableData *data = [[NSMutableData alloc] init];
    
    while (stream.hasBytesAvailable) {
        len = [stream read:buffer maxLength:sizeof(buffer)];
        
        if (len > 0) {
            [data appendBytes:(const void *)buffer length:len];
        }
    }
    
    NSString *message = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if (message) {
//        NSLog(@"CommunicationHelper: received message: %@", message);
        
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
//            NSLog(@"CommunicationHelper: %@: NSStreamEventOpenCompleted", streamString);
            
            if ([self.delegate respondsToSelector:@selector(communicationHelperDidConnectToHost:)]) {
                [self.delegate communicationHelperDidConnectToHost:self];
            }
            
            [self stopReconnectiong];
            
            break;
            
        case NSStreamEventHasBytesAvailable:
//            NSLog(@"CommunicationHelper: %@: NSStreamEventHasBytesAvailable", streamString);
            
            if ([stream isKindOfClass:[NSInputStream class]]) {
                [self receiveDataFromInputStream:(NSInputStream *)stream];
            }
            
            break;
            
        case NSStreamEventHasSpaceAvailable:
//            NSLog(@"CommunicationHelper: %@: NSStreamEventHasSpaceAvailable", streamString);
            break;
        
        case NSStreamEventEndEncountered:
//            NSLog(@"CommunicationHelper: %@: NSStreamEventEndEncountered", streamString);

            [self closeStream:stream];
            
            if ([self.delegate respondsToSelector:@selector(communicationHelperDidDisconnectFromHost:)]) {
                [self.delegate communicationHelperDidDisconnectFromHost:self];
            }
            
            [self startReconnecting];
            
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"CommunicationHelper: %@: NSStreamEventErrorOccurred: %@", streamString, stream.streamError.localizedDescription);
            
            if ([self.delegate respondsToSelector:@selector(communicationHelper:encounteredAnError:)]) {
                [self.delegate communicationHelper:self encounteredAnError:stream.streamError];
            }
            
            [self startReconnecting];
            
            break;
            
        case NSStreamEventNone:
            NSLog(@"CommunicationHelper: %@: NSStreamEventNone", streamString);
            break;
    }
}

@end
