//
//  MainViewController.m
//  RPi_Control
//
//  Created by Crt Gregoric on 26. 10. 14.
//  Copyright (c) 2014 crtgregoric. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MainViewController.h"
#import "CommunicationHelper.h"
#import "StreamHelper.h"
#import "MessageComposer.h"
#import "DifferentialSteeringHelper.h"

#import "VideoFeedView.h"
#import "ControlView.h"
#import "LedSegmentControl.h"

@interface MainViewController () <CommunicationHelperDelegate, ControlViewDelegate, StreamHelperDelegate>

@property (nonatomic, strong) CommunicationHelper *communicationHelper;
@property (nonatomic, strong) StreamHelper *streamHelper;

@property (weak, nonatomic) IBOutlet VideoFeedView *streamFeedView;
@property (weak, nonatomic) IBOutlet UIView *streamFeedAnimationView;

@property (weak, nonatomic) IBOutlet ControlView *positionControlView;
@property (weak, nonatomic) IBOutlet ControlView *tiltControlView;
@property (weak, nonatomic) IBOutlet ControlView *brightnessControlView;

@property (weak, nonatomic) IBOutlet LedSegmentControl *ledSegment;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brightnessControlViewBottomConstraint;

@end

@implementation MainViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicationHelper = [[CommunicationHelper alloc] init];
    self.communicationHelper.delegate = self;
    
    self.positionControlView.type = ControlViewTypeRobotPosition;
    self.positionControlView.delegate = self;
    self.positionControlView.visible = YES;

    self.tiltControlView.type = ControlViewTypeCameraTilt;
    self.tiltControlView.delegate = self;
    self.tiltControlView.visible = YES;
    
    self.brightnessControlView.type = ControlViewTypeLedBrightness;
    self.brightnessControlView.delegate = self;
    self.brightnessControlView.visible = NO;

    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.brightnessControlView updateCircleViewPosition:YES animated:NO];
}

#pragma mark - Button actions

- (IBAction)shutdownButtonPressed:(id)sender
{
    [self.communicationHelper sendMessage:[MessageComposer shutdownMessage]];
}

#pragma mark - Helper methods

- (void)setupUI {
    self.activityIndicator.alpha = 0.0f;
    self.brightnessControlViewBottomConstraint.constant = -self.brightnessControlView.frame.size.height;
    
    [self.view layoutIfNeeded];
}

- (void)showBrightnessControlView:(BOOL)show {
    BOOL updateConstraint = NO;
    
    if (self.brightnessControlView.visible && !show) {
        updateConstraint = YES;
        self.brightnessControlViewBottomConstraint.constant = -self.brightnessControlView.frame.size.height;
        
    } else if (!self.brightnessControlView.visible && show) {
        [self.brightnessControlView updateCircleViewPosition:NO animated:NO];
        updateConstraint = YES;
        self.brightnessControlViewBottomConstraint.constant = 20.0f;
    }
    
    if (updateConstraint) {
        self.brightnessControlView.visible = show;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)showActivityIndicator {
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:0.5f animations:^{
        self.activityIndicator.alpha = 1.0f;
    }];
}

- (void)hideActivityIndicator {
    if (self.activityIndicator.isAnimating) {
        [UIView animateWithDuration:0.5f animations:^{
            self.activityIndicator.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            [self.activityIndicator stopAnimating];
        }];
    }
}

- (void)showAnimationView {
    [UIView animateWithDuration:0.5f animations:^{
        self.streamFeedAnimationView.alpha = 1.0f;
    }];
}

- (void)hideAnimationView {
    [UIView animateWithDuration:0.5f animations:^{
        self.streamFeedAnimationView.alpha = 0.0f;
    }];
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
        [self showActivityIndicator];
    }
    
    [self.ledSegment setSelectedSegmentIndex:0];
    [self showBrightnessControlView:NO];
}

- (void)communicationHelperDidDisconnectFromHost:(CommunicationHelper *)helper {
    self.statusLabel.text = @"Not connected";
    self.statusLabel.backgroundColor = [UIColor redColor];
    
    [self.ledSegment setSelectedSegmentIndex:0];
    [self showBrightnessControlView:NO];

    if (self.streamHelper) {
        [self.streamHelper stop];
        self.streamHelper = nil;
        [self showAnimationView];
    }
    [self hideActivityIndicator];
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
    NSString *message;
    
    if (controlView.type == ControlViewTypeCameraTilt) {
        message = [MessageComposer messageWithCommandType:controlView.type cameraTilt:position.y];
        
    } else if (controlView.type == ControlViewTypeRobotPosition) {
        position = [DifferentialSteeringHelper differentialMotorSpeedForCoordinate:position inCircleWithRadius:controlView.shapeRadius];
        message = [MessageComposer messageWithCommandType:controlView.type position:position];
        
    } else if (controlView.type == ControlViewTypeLedBrightness) {
        int state = self.ledSegment.selectedSegmentIndex;
        message = [MessageComposer messageWithCommandType:controlView.type ledBrightness:position.x ledState:state];
    }

    [self.communicationHelper sendMessage:message];
    NSLog(@"%@: sent: %@", controlView.typeString, message);
}

- (void)controlViewDidEndChangigPosition:(ControlView *)controlView {
    NSLog(@"position change ended");
    
    if (controlView.type == ControlViewTypeRobotPosition) {
        NSString *message = [MessageComposer messageWithCommandType:controlView.type position:CGPointZero];
        [self.communicationHelper sendMessage:message];
    }
}

#pragma mark - StreamHelperDelegate

- (void)streamerHelperDidStartDisplayingVideo:(StreamHelper *)streamerHelper {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideActivityIndicator];
        [self hideAnimationView];
    });
}

#pragma mark - Segment control methods

- (IBAction)ledSegmentValueChanged:(UISegmentedControl *)sender {
    NSString *message;
    if (sender.selectedSegmentIndex == 0) {
        [self showBrightnessControlView:NO];
        message = [MessageComposer allLedOffMessageWithCommandType:self.brightnessControlView.type];
        NSLog(@"Segment sent: all led off");

    } else {
        if (self.brightnessControlView.visible) {
            [self.brightnessControlView updateCircleViewPosition:NO animated:NO];
        }
        
        [self showBrightnessControlView:YES];
        message = [MessageComposer messageWithCommandType:self.brightnessControlView.type ledOnForState:sender.selectedSegmentIndex];
        NSLog(@"Segment sent: led state: %d", sender.selectedSegmentIndex);
    }
    
    [self.communicationHelper sendMessage:message];
}


@end
