//
//  MainViewController.m
//  RPi_Control
//
//  Created by Crt Gregoric on 26. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "MainViewController.h"
#import "CommunicationHelper.h"
#import "StreamHelper.h"
#import "ControlView.h"
#import "VideoFeedView.h"

@interface MainViewController () <CommunicationHelperDelegate, ControlViewDelegate, StreamHelperDelegate>

@property (nonatomic, strong) CommunicationHelper *communicationHelper;
@property (nonatomic, strong) StreamHelper *streamHelper;

@property (weak, nonatomic) IBOutlet VideoFeedView *streamFeedView;
@property (weak, nonatomic) IBOutlet UIView *streamFeedAnimationView;

@property (weak, nonatomic) IBOutlet ControlView *leftControlView;
@property (weak, nonatomic) IBOutlet ControlView *rightControlView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

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
    
    self.activityIndicator.alpha = 0.0f;
}

#pragma mark - Helper methods

- (NSString *)prepareMessageForControlView:(ControlView *)controlView andPosition:(CGPoint)position {
    int px = position.x * 100;
    int py = position.y * 100;
    return [NSString stringWithFormat:@"%d %d %d|", (int)controlView.position, px, py];
}

#pragma mark - CommunicationHelperDelegate

- (void)communicationHelper:(CommunicationHelper *)helper didReceiveMessage:(NSString *)message {
    NSLog(@"message: %@", message);
}

- (void)communicationHelperDidConnectToHost:(CommunicationHelper *)helper {
    self.statusLabel.text = @"Connected";
    self.statusLabel.backgroundColor = [UIColor greenColor];
    
    if (!self.streamHelper) {
        self.streamHelper = [[StreamHelper alloc] initWithVideoFeedView:self.streamFeedView delegate:self];

        [self.activityIndicator startAnimating];
        [UIView animateWithDuration:0.5f animations:^{
            self.activityIndicator.alpha = 1.0f;
        }];
    }
}

- (void)communicationHelperDidDisconnectFromHost:(CommunicationHelper *)helper {
    self.statusLabel.text = @"Not connected";
    self.statusLabel.backgroundColor = [UIColor redColor];
    
    if (self.streamHelper) {
        [self.streamHelper stop];
        self.streamHelper = nil;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.streamFeedAnimationView.alpha = 1.0f;
        }];
    }
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
    NSString *message = [self prepareMessageForControlView:controlView andPosition:position];
    [self.communicationHelper sendMessage:message];
    
    NSString *positionString = (controlView.position == ControlViewPositionLeft) ? @"left" : @"right";
    NSLog(@"%@: sent: %@", positionString, message);
}

- (void)controlViewDidEndChangigPosition:(ControlView *)controlView {
    NSLog(@"position change ended");
    if (controlView.position == ControlViewPositionRight) {
        NSString *message = [self prepareMessageForControlView:controlView andPosition:CGPointZero];
        [self.communicationHelper sendMessage:message];
    }
}

#pragma mark - StreamHelperDelegate

- (void)streamerHelperDidStartDisplayingVideo:(StreamHelper *)streamerHelper
{
    if (self.activityIndicator.isAnimating) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5f animations:^{
                self.activityIndicator.alpha = 0.0f;
                self.streamFeedAnimationView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self.activityIndicator stopAnimating];
            }];
        });
    }
}

@end
