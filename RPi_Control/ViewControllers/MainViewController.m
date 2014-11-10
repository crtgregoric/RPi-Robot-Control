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
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation MainViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicationHelper = [[CommunicationHelper alloc] init];
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
    self.errorLabel.alpha = 1.0;
    self.errorLabel.text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];

    [UIView animateWithDuration:0.5 delay:4.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.errorLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.errorLabel.text = @" ";
        }
    }];
}

#pragma mark - ControlViewDelegate

- (void)controlView:(ControlView *)controlView isChangingPositionTo:(CGPoint)position {
    int px = position.x * 100;
    int py = position.y * 100;

    NSString *test = [NSString stringWithFormat:@"%d %d %d|", (int)controlView.position, px, py];
    [self.communicationHelper sendMessage:[NSString stringWithFormat:@"%@%@%@", test, test, test]];
    
    NSString *message = [NSString stringWithFormat:@"%d %d %d|", (int)controlView.position, px, py];
//    [self.communicationHelper sendMessage:message];
    
    NSString *positionString = (controlView.position == ControlViewPositionLeft) ? @"left" : @"right";
    NSLog(@"%@: sent: %@", positionString, message);
}

- (void)controlViewDidEndChangigPosition:(ControlView *)controlView {
    NSLog(@"position change ended");
}

@end
