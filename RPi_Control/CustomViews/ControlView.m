//
//  ControlView.m
//  RPi_Control
//
//  Created by Crt Gregoric on 27. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ControlView.h"

@interface ControlView ()

@end

@implementation ControlView

- (void)prepareForInterfaceBuilder {
    [self setupUI];
}

- (void)awakeFromNib {
    [self setupUI];
}

#pragma mark - Setup

- (void)setupUI {
    self.layer.borderWidth = self.shapeBorderWidth;
    self.layer.borderColor = self.shapeBorderColor.CGColor;
    self.layer.backgroundColor = self.shapeBackgroundColor.CGColor;
//    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Helper methods

#pragma mark - Getter methods

- (CGFloat)shapeBorderWidth {
    if (!_shapeBorderWidth) {
        _shapeBorderWidth = 1.0;
    }
    return _shapeBorderWidth;
}

- (UIColor *)shapeBorderColor {
    if (!_shapeBorderColor) {
        _shapeBorderColor = [UIColor blackColor];
    }
    return  _shapeBorderColor;
}

- (UIColor *)shapeBackgroundColor {
    if (!_shapeBackgroundColor) {
        _shapeBackgroundColor = [UIColor colorWithWhite:0.50 alpha:0.25];
    }
    return _shapeBackgroundColor;
}

@end
