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

@interface MainViewController () <ControlViewDelegate>

@property (nonatomic, strong) CommunicationHelper *communicationHelper;

@property (nonatomic, weak) IBOutlet ControlView *leftControlView;
@property (nonatomic, weak) IBOutlet ControlView *rightControlView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.communicationHelper = [[CommunicationHelper alloc] init];
    
    self.leftControlView.position = ControlViewPositionLeft;
    self.leftControlView.delegate = self;

    self.rightControlView.position = ControlViewPositionRight;
    self.rightControlView.delegate = self;
}

#pragma mark - ControlViewDelegate

- (void)controlView:(ControlView *)controlView isChangingPositionTo:(CGPoint)position {
    NSLog(@"position x: %.1f, y: %.1f", position.x, position.y);
}

- (void)controlViewDidEndChangigPosition:(ControlView *)controlView {
    NSLog(@"position change ended");
}

@end
