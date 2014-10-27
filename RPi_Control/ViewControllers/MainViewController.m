//
//  MainViewController.m
//  RPi_Control
//
//  Created by Crt Gregoric on 26. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "MainViewController.h"
#import "ControlView.h"

@interface MainViewController ()

@property (nonatomic, weak) IBOutlet ControlView *leftControlView;
@property (nonatomic, weak) IBOutlet ControlView *rightControlView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
