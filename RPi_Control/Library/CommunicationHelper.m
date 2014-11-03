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

#pragma mark - Sending data

- (void)sendCommand:(NSString *)command {
    NSData *data = [[NSData alloc] initWithData:[command dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:data.bytes maxLength:data.length];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    NSString *streamString = stream == self.inputStream ? @"inputStream" : @"outputStream";
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"%@: NSStreamEventOpenCompleted", streamString);
            break;
            
        case NSStreamEventHasBytesAvailable:
            NSLog(@"%@: NSStreamEventHasBytesAvailable", streamString);
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"%@: NSStreamEventHasSpaceAvailable", streamString);
            break;
        
        case NSStreamEventEndEncountered:
            NSLog(@"%@: NSStreamEventEndEncountered", streamString);
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"%@: NSStreamEventErrorOccurred", streamString);
            break;
            
        case NSStreamEventNone:
            NSLog(@"%@: NSStreamEventNone", streamString);
            break;
    }
}

@end
