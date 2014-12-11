//
//  MainViewController.m
//  RPi_Control
//
//  Created by Crt Gregoric on 26. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MainViewController.h"
#import "CommunicationHelper.h"
#import "StreamHelper.h"
#import "MessageComposer.h"

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

@property (weak, nonatomic) IBOutlet UIView *brightnessBackgroundView;
@property (nonatomic) BOOL brightnessControlVisible;

@property (weak, nonatomic) IBOutlet LedSegmentControl *ledSegment;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brightnessBackgroundBottomConstraint;

@end

@implementation MainViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicationHelper = [[CommunicationHelper alloc] init];
    self.communicationHelper.delegate = self;
    
    self.positionControlView.type = ControlViewTypeRobotPosition;
    self.positionControlView.delegate = self;

    self.tiltControlView.type = ControlViewTypeCameraTilt;
    self.tiltControlView.delegate = self;
    
    self.brightnessControlView.type = ControlViewTypeLedBrightness;
    self.brightnessControlView.delegate = self;

    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.brightnessControlView updateCircleViewPositionConditional:YES animated:NO];
}

#pragma mark - Helper methods

- (void)setupUI {
    self.brightnessBackgroundView.backgroundColor = [UIColor colorWithWhite:0.50 alpha:0.25];
    self.brightnessBackgroundView.layer.borderWidth = 1.0f;
    self.brightnessBackgroundView.layer.borderColor = [UIColor blackColor].CGColor;
    self.brightnessBackgroundView.layer.cornerRadius = self.brightnessBackgroundView.frame.size.height/2;
    self.brightnessBackgroundBottomConstraint.constant = -self.brightnessBackgroundView.frame.size.height;
    
    self.activityIndicator.alpha = 0.0f;
    
    [self.view layoutIfNeeded];
}

- (void)setBrightnessControlViewVisible:(BOOL)visible {
    BOOL updateConstraint = NO;
    
    if (self.brightnessControlVisible && !visible) {
        updateConstraint = YES;
        self.brightnessBackgroundBottomConstraint.constant = -self.brightnessBackgroundView.frame.size.height;
        
    } else if (!self.brightnessControlVisible && visible) {
        [self.brightnessControlView updateCircleViewPositionConditional:NO animated:NO];
        updateConstraint = YES;
        self.brightnessBackgroundBottomConstraint.constant = 20.0f;
    }
    
    if (updateConstraint) {
        self.brightnessControlVisible = visible;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
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
    
    [self.ledSegment setSelectedSegmentIndex:0];
    [self setBrightnessControlViewVisible:NO];
}

- (void)communicationHelperDidDisconnectFromHost:(CommunicationHelper *)helper {
    self.statusLabel.text = @"Not connected";
    self.statusLabel.backgroundColor = [UIColor redColor];
    
    [self.ledSegment setSelectedSegmentIndex:0];
    [self setBrightnessControlViewVisible:NO];
    
    if (self.streamHelper) {
        [self.streamHelper stop];
        self.streamHelper = nil;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.streamFeedAnimationView.alpha = 1.0f;
            self.activityIndicator.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            [self.activityIndicator stopAnimating];
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
    NSString *message;
    
    if (controlView.type == ControlViewTypeCameraTilt) {
        message = [MessageComposer messageWithCommandType:controlView.type cameraTilt:position.y];
        
    } else if (controlView.type == ControlViewTypeRobotPosition) {
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

#pragma mark - Segment control methods

- (IBAction)ledSegmentValueChanged:(UISegmentedControl *)sender {
    NSString *message;
    if (sender.selectedSegmentIndex == 0) {
        [self setBrightnessControlViewVisible:NO];
        message = [MessageComposer allLedOffMessageWithCommandType:self.brightnessControlView.type];
        NSLog(@"Segment sent: all led off");

    } else {
        if (self.brightnessControlVisible) {
            [self.brightnessControlView updateCircleViewPositionConditional:NO animated:YES];
        }
        
        [self setBrightnessControlViewVisible:YES];
        message = [MessageComposer messageWithCommandType:self.brightnessControlView.type ledOnForState:sender.selectedSegmentIndex];
        NSLog(@"Segment sent: led state: %d", sender.selectedSegmentIndex);
    }
    
    [self.communicationHelper sendMessage:message];
}


@end
