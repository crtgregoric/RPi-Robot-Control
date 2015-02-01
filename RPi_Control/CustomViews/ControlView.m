//
//  ControlView.m
//  RPi_Control
//
//  Created by Crt Gregoric on 27. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ControlView.h"
#import "MathHelpers.h"

@interface ControlView ()

@property (nonatomic, strong) UIView *circleView;
@property (nonatomic) CGVector offsetVector;

@property (nonatomic) BOOL didUpdateCircleViewPosition;

@end

@implementation ControlView

- (void)prepareForInterfaceBuilder {
    [self setupUI];
}

- (void)awakeFromNib {
    [self setupUI];
}

#pragma mark - Setup methods

- (void)setupUI {
    self.layer.borderWidth = self.shapeBorderWidth;
    self.layer.borderColor = self.shapeBorderColor.CGColor;
    self.layer.backgroundColor = self.shapeBackgroundColor.CGColor;
    
    self.layer.cornerRadius = [self viewRadius];
    
    [self addSubview:self.circleView];
    self.circleView.userInteractionEnabled = NO;
}

#pragma mark - UIControl overriden methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint panLocation = [touch locationInView:self];
    
    CGPoint circleCenter = [self viewCenter];
    CGFloat circleRadius = [self viewRadius];
    
    if (![MathHelpers circleWithCenter:circleCenter andRadius:circleRadius containsPoint:panLocation]) {
        return NO;
    }
    
    CGPoint center = self.circleView.center;
    CGFloat dx = center.x - panLocation.x;
    CGFloat dy = center.y - panLocation.y;
    self.offsetVector = CGVectorMake(dx, dy);
    
    if ([self.delegate respondsToSelector:@selector(controlViewWillBeginChangingPosition:)]) {
        [self.delegate controlViewWillBeginChangingPosition:self];
    }

    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint panLocation = [touch locationInView:self];

    CGFloat x = panLocation.x + self.offsetVector.dx;
    CGFloat y = panLocation.y + self.offsetVector.dy;
    CGPoint newCenter = CGPointMake(x, y);
    
    CGPoint circleCenter = [self viewCenter];
    CGFloat circleRadius = [self viewRadius];
    
    if (self.type == ControlViewTypeCameraTilt) {
        newCenter = CGPointMake(circleCenter.x, newCenter.y);
    } else if (self.type == ControlViewTypeLedBrightness) {
        newCenter = CGPointMake(newCenter.x, circleCenter.y);
    }

    if (![MathHelpers circleWithCenter:circleCenter andRadius:circleRadius containsPoint:newCenter]) {
        newCenter = [MathHelpers coordinatesForPoint:newCenter onCircleWithCenter:circleCenter andRadius:circleRadius];
        [self adjustOffsetVector];
    }
    
    [self repositionCircleViewToPosition:newCenter];

    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.type == ControlViewTypeRobotPosition) {
        [UIView animateWithDuration:0.3 animations:^{
            self.circleView.center = [self viewCenter];
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(controlViewDidEndChangigPosition:)]) {
        [self.delegate controlViewDidEndChangigPosition:self];
    }
}

#pragma mark - Helper methods

- (void)updateCircleViewPositionConditional:(BOOL)conditional animated:(BOOL)animated {
    if (!self.didUpdateCircleViewPosition || !conditional) {
        CGPoint viewCenter = [self viewCenter];
        viewCenter.x = self.bounds.size.width;
        
        CGFloat duration = animated ? 0.3f : 0.0f;
        [UIView animateWithDuration:duration animations:^{
            self.circleView.center = viewCenter;
        }];
        
        self.didUpdateCircleViewPosition = YES;
    }
}

- (CGFloat)viewRadius {
    return self.frame.size.width > self.frame.size.height ? self.frame.size.width/2 : self.frame.size.height/2;
}

- (CGPoint)viewCenter {
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)adjustOffsetVector {
    CGFloat dx = self.offsetVector.dx;
    CGFloat dy = self.offsetVector.dy;
    
    CGFloat delta = 0.75;
    
    if (dx > 0) {
        dx -= delta;
    } else if (dx < 0) {
        dx += delta;
    }
    
    if (dy > 0) {
        dy -= delta;
    } else if (dy < 0) {
        dy += delta;
    }

    self.offsetVector = CGVectorMake(dx, dy);
}

- (void)repositionCircleViewToPosition:(CGPoint)position {
    self.circleView.center = position;
    
    if ([self.delegate respondsToSelector:@selector(controlView:isChangingPositionTo:)]) {
        CGPoint center = [self viewCenter];
        CGFloat x = (position.x - center.x) / (self.frame.size.width/2);
        CGFloat y = (center.y - position.y) / (self.frame.size.height/2);
        
        if (self.type == ControlViewTypeLedBrightness) {
            x = position.x / self.frame.size.width;
            y = 0;
        }
        
        [self.delegate controlView:self isChangingPositionTo:CGPointMake(x, y)];
    }
}

#pragma mark - Getter methods

- (CGFloat)shapeRadius {
    return [self viewRadius];
}

- (NSString *)typeString {
    if (self.type == ControlViewTypeCameraTilt) {
        return @"Camera tilt";
    } else if (self.type == ControlViewTypeLedBrightness) {
        return @"Led brightness";
    }
    return @"Robot position";
}

- (UIView *)circleView {
    if (!_circleView) {
        _circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.circleRadius*2, self.circleRadius*2)];
        _circleView.center = [self viewCenter];
        _circleView.layer.backgroundColor = self.circleColor.CGColor;
        _circleView.layer.cornerRadius = self.circleRadius;
    }
    return _circleView;
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
