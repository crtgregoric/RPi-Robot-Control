//
//  MainViewController.m
//  RPi_Control
//
//  Created by Crt Gregoric on 26. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "MainViewController.h"
#import "CommunicationHelper.h"
#import "ControlView.h"

@interface MainViewController () <CommunicationHelperDelegate, ControlViewDelegate>

@property (nonatomic, strong) CommunicationHelper *communicationHelper;

@property (nonatomic, weak) IBOutlet ControlView *leftControlView;
@property (nonatomic, weak) IBOutlet ControlView *rightControlView;

#pragma mark - IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation MainViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicationHelper = [[CommunicationHelper alloc] init];
    [self.communicationHelper connect];
    self.communicationHelper.delegate = self;
    
    self.leftControlView.position = ControlViewPositionLeft;
    self.leftControlView.delegate = self;

    self.rightControlView.position = ControlViewPositionRight;
    self.rightControlView.delegate = self;
}

#pragma mark - CommunicationHelperDelegate

- (void)communicationHelper:(CommunicationHelper *)helper didReceiveMessage:(NSString *)message {
    NSLog(@"message: %@", message);
}

- (void)communicationHelperDidConnectToHost:(CommunicationHelper *)helper {
    self.statusLabel.text = @"Connected";
    self.statusLabel.backgroundColor = [UIColor greenColor];
}

- (void)communicationHelperDidDisconnectFromHost:(CommunicationHelper *)helper {
    self.statusLabel.text = @"Not connected";
    self.statusLabel.backgroundColor = [UIColor redColor];
}

- (void)communicationHelper:(CommunicationHelper *)helper encounteredAnError:(NSError *)error {
    NSLog(@"communication error: %@", error.localizedDescription);
}

#pragma mark - ControlViewDelegate

- (void)controlView:(ControlView *)controlView isChangingPositionTo:(CGPoint)position {
    NSLog(@"position x: %.1f, y: %.1f", position.x, position.y);
    [self.communicationHelper sendMessage:[NSString stringWithFormat:@"0 %d", (int)(position.y * 100)]];
}

- (void)controlViewDidEndChangigPosition:(ControlView *)controlView {
    NSLog(@"position change ended");
}

@end
