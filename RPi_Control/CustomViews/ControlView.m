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

@end

@implementation ControlView

- (void)prepareForInterfaceBuilder {
    [self setupUI];
}

- (void)awakeFromNib {
    [self setup];
    [self setupUI];
}

#pragma mark - Setup methods

- (void)setup {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [self addGestureRecognizer:panGesture];
}

- (void)setupUI {
    self.layer.borderWidth = self.shapeBorderWidth;
    self.layer.borderColor = self.shapeBorderColor.CGColor;
    self.layer.backgroundColor = self.shapeBackgroundColor.CGColor;
    
    self.layer.cornerRadius = [self viewRadius];
    
    [self addSubview:self.circleView];
}

#pragma mark - Action methods

- (void)panGestureRecognized:(UIPanGestureRecognizer *)panGesture {
    CGPoint panLocation = [panGesture locationInView:self];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint center = self.circleView.center;
        CGFloat dx = center.x - panLocation.x;
        CGFloat dy = center.y - panLocation.y;
        self.offsetVector = CGVectorMake(dx, dy);
        
        if ([self.delegate respondsToSelector:@selector(controlViewWillBeginChangingPosition:)]) {
            [self.delegate controlViewWillBeginChangingPosition:self];
        }
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat x = panLocation.x + self.offsetVector.dx;
        CGFloat y = panLocation.y + self.offsetVector.dy;
        CGPoint newCenter = CGPointMake(x, y);
        
        CGPoint circleCenter = [self viewCenter];
        CGFloat circleRadius = [self viewRadius];
        
        if (self.type == ControlViewTypeRobotPosition) {
            if (![MathHelpers circleWithCenter:circleCenter andRadius:circleRadius containsPoint:newCenter]) {
                newCenter = [MathHelpers coordinatesForPoint:newCenter onCircleWithCenter:circleCenter andRadius:circleRadius];
                [self adjustOffsetVector];
                
            }
            
            [self repositionCircleViewToPosition:newCenter];
            
        } else if (self.type == ControlViewTypeCameraTilt) {
            newCenter = CGPointMake(circleCenter.x, newCenter.y);
            
            if ([MathHelpers circleWithCenter:circleCenter andRadius:circleRadius containsPoint:newCenter]) {
                [self repositionCircleViewToPosition:newCenter];
                
            } else {
                [self adjustOffsetVector];
                
            }
            
        } else if (self.type == ControlViewTypeLedBrightness) {
            newCenter = CGPointMake(newCenter.x, circleCenter.y);
            if ([MathHelpers rect:self.bounds containsPoint:newCenter]) {
                [self repositionCircleViewToPosition:newCenter];
            }
        }
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        if (self.type == ControlViewTypeRobotPosition) {
            [UIView animateWithDuration:0.3 animations:^{
                self.circleView.center = [self viewCenter];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(controlViewDidEndChangigPosition:)]) {
            [self.delegate controlViewDidEndChangigPosition:self];
        }
    }
}

#pragma mark - Helper methods

- (CGFloat)viewRadius {
    return self.frame.size.width < self.frame.size.height ? self.frame.size.width/2 : self.frame.size.height/2;
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
        
        [self.delegate controlView:self isChangingPositionTo:CGPointMake(x, y)];
    }
}

#pragma mark - Getter methods

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
