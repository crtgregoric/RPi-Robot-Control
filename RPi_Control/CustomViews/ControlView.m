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

@property (nonatomic, strong) CAShapeLayer *circleShape;

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
    
    self.layer.cornerRadius = [self viewRadius];
    
    [self.layer addSublayer:self.circleShape];
}

#pragma mark - Helper methods

- (CGFloat)viewRadius {
    return self.frame.size.width < self.frame.size.height ? self.frame.size.width/2 : self.frame.size.height/2;
}

- (CGPoint)viewCenter {
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma mark - Getter methods

- (CAShapeLayer *)circleShape {
    if (!_circleShape) {
        _circleShape = [CAShapeLayer layer];
        
        CGPoint center = [self viewCenter];
        _circleShape.path = [UIBezierPath bezierPathWithArcCenter:center radius:self.circleRadius startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        _circleShape.fillColor = self.circleColor.CGColor;
    }
    
    return _circleShape;
}

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

- (CGFloat)circleRadius {
    if (!_circleRadius) {
        _circleRadius = 10.0;
    }
    return _circleRadius;
}

- (UIColor *)circleColor {
    if (!_circleColor) {
        _circleColor = [UIColor blackColor];
    }
    return _circleColor;
}

@end
