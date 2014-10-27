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

#pragma mark - Setup

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
    
    switch ([panGesture state]) {
        case UIGestureRecognizerStateBegan:
            {
                CGPoint center = [self viewCenter];
                CGFloat dx = center.x - panLocation.x;
                CGFloat dy = center.y - panLocation.y;
                self.offsetVector = CGVectorMake(dx, dy);
            }
            break;
        case UIGestureRecognizerStateChanged:
            //
            // This method changes for different control view position
            //
            {
                CGFloat x = panLocation.x + self.offsetVector.dx;
                CGFloat y = panLocation.y + self.offsetVector.dy;
                CGPoint newCenter = CGPointMake(x, y);
                
                CGPoint circleCenter = [self viewCenter];
                CGFloat circleRadius = [self viewRadius];
                
                if (![MathHelpers circleWithCenter:circleCenter andRadius:circleRadius containsPoint:newCenter]) {
                    newCenter = [MathHelpers coordinatesForPoint:panLocation onCircleWithCenter:circleCenter andRadius:circleRadius];
                    self.offsetVector = CGVectorMake(0, 0);
                }
                
                self.circleView.center = newCenter;
            }
            break;
        case UIGestureRecognizerStateEnded:
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.circleView.center = [self viewCenter];
                }];
                self.offsetVector = CGVectorMake(0, 0);
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Helper methods

- (CGFloat)viewRadius {
    return self.frame.size.width < self.frame.size.height ? self.frame.size.width/2 : self.frame.size.height/2;
}

- (CGPoint)viewCenter {
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma mark - Getter methods

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
