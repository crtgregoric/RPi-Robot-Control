//
//  ControlView.m
//  RPi_Control
//
//  Created by Crt Gregoric on 26. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "ControlView.h"

@interface ControlView ()

@end

@implementation ControlView

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
    return _shapeBorderColor;
}

- (UIColor *)shapeBackgroundColor {
    if (!_shapeBackgroundColor) {
        _shapeBackgroundColor = [UIColor lightGrayColor];
    }
    return _shapeBackgroundColor;
}

@end
