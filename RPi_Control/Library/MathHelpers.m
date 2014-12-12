//
//  MathHelpers.m
//  RPi_Control
//
//  Created by Crt Gregoric on 27. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "MathHelpers.h"

@implementation MathHelpers

+ (BOOL)circleWithCenter:(CGPoint)center andRadius:(CGFloat)radius containsPoint:(CGPoint)point {
    CGFloat dx = pow((point.x - center.x), 2);
    CGFloat dy = pow((point.y - center.y), 2);
    return sqrt(dx + dy) < radius;
}

+ (CGPoint)coordinatesForPoint:(CGPoint)point onCircleWithCenter:(CGPoint)center andRadius:(CGFloat)radius {
    CGFloat angle = [MathHelpers angleForPoint:point onCircleWithCenter:center andRadius:radius];
        
    CGFloat x = center.x + radius * cos(angle);
    CGFloat y = center.y + radius * sin(angle);
    
    return CGPointMake(x, y);
}

+ (CGFloat)angleForPoint:(CGPoint)point onCircleWithCenter:(CGPoint)center andRadius:(CGFloat)radius {
    CGFloat dx = point.x - center.x;
    CGFloat dy = point.y - center.y;

    return atan2(dy, dx);
}

+ (CGFloat)radianToDegrees:(CGFloat)angle {
    return angle * (180.0f / M_PI);
}

+ (CGFloat)degreesToRadian:(CGFloat)angle {
    return angle * (M_PI / 180.0f);
}

+ (BOOL)rect:(CGRect)rect containsPoint:(CGPoint)point
{
    return CGRectContainsPoint(rect, point);
}

@end
