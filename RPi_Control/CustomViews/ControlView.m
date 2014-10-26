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

@synthesize shapeBorderWidth = _shapeBorderWidth;
@synthesize shapeBorderColor = _shapeBorderColor;
@synthesize shapeFillColor = _shapeFillColor;

- (void)prepareForInterfaceBuilder {
    CAShapeLayer *a = self.circleShape;    
}

- (void)awakeFromNib {
    CAShapeLayer *a = self.circleShape;
}

#pragma mark - Helper methods

- (CGFloat)circleRadius {
    return self.bounds.size.width < self.bounds.size.height ? self.bounds.size.width/2 : self.bounds.size.height/2;
}

#pragma mark - Getters and setters

- (CAShapeLayer *)circleShape {
    if (!_circleShape) {
        _circleShape = [CAShapeLayer layer];
        
        CGFloat radius = [self circleRadius] - self.shapeBorderWidth/2;
        _circleShape.path = [UIBezierPath bezierPathWithArcCenter:self.center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        
        _circleShape.lineWidth = self.shapeBorderWidth;
        _circleShape.strokeColor = self.shapeBorderColor.CGColor;
        _circleShape.fillColor = self.shapeFillColor.CGColor;
        
        [self.layer addSublayer:_circleShape];
        self.backgroundColor = [UIColor clearColor];
    }
    return _circleShape;
}

- (void)setShapeBorderWidth:(CGFloat)shapeBorderWidth {
    if (shapeBorderWidth >= 0 && shapeBorderWidth <= [self circleRadius]) {
        _shapeBorderWidth = shapeBorderWidth;
        self.circleShape.lineWidth = shapeBorderWidth;
    }
}

- (CGFloat)shapeBorderWidth {
    if (!_shapeBorderWidth) {
        _shapeBorderWidth = 1.0;
    }
    return _shapeBorderWidth;
}

- (void)setShapeBorderColor:(UIColor *)shapeBorderColor {
    _shapeBorderColor = shapeBorderColor;
    self.circleShape.strokeColor = shapeBorderColor.CGColor;
}

- (UIColor *)shapeBorderColor {
    if (!_shapeBorderColor) {
        _shapeBorderColor = [UIColor blackColor];
    }
    return _shapeBorderColor;
}

- (void)setShapeFillColor:(UIColor *)shapeFillColor {
    _shapeFillColor = shapeFillColor;
    self.circleShape.fillColor = shapeFillColor.CGColor;
}

- (UIColor *)shapeFillColor {
    if (!_shapeFillColor) {
        _shapeFillColor = [UIColor colorWithWhite:0.5 alpha:0.25];
    }
    return _shapeFillColor;
}

@end
