//
//  DifferentialSteeringHelper.m
//  RPi_Control
//
//  Created by Crt Gregoric on 12. 12. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import "DifferentialSteeringHelper.h"
#import "MathHelpers.h"

@implementation DifferentialSteeringHelper

+ (CGPoint)differentialMotorSpeedForCoordinate:(CGPoint)coordinate inCircleWithRadius:(CGFloat)radius {

    CGFloat distance = sqrt(pow(coordinate.x, 2) + pow(coordinate.y, 2));
    CGFloat angle = [MathHelpers angleForPoint:coordinate onCircleWithCenter:CGPointZero andRadius:radius];
    angle = [MathHelpers radianToDegrees:angle];
    
    if (coordinate.x >= 0 && coordinate.y >= 0) {
        //
        // I. quadrant
        //
        angle = angle - 45.0f;
        coordinate.x = distance;
        coordinate.y = angle / 45.0f;
        
    } else if (coordinate.x <= 0 && coordinate.y >= 0) {
        //
        // II. quadrant
        //
        angle = angle - 135.0f;
        coordinate.x = -angle / 45.0f;
        coordinate.y = distance;
        
    } else if (coordinate.x <= 0 && coordinate.y <= 0) {
        //
        // III. quadrant
        //
        angle = -(135.0f + angle);
        coordinate.x = -distance;
        coordinate.y = angle / 45.0f;

    } else {
        //
        // IV. quadrant
        //
        angle = (45.0f + angle);
        coordinate.x = angle / 45.0f;
        coordinate.y = -distance;

    }
    
//    NSLog(@"x: %.1f, y:%.1f", coordinate.x, coordinate.y);
//    NSLog(@"\n\n");
    
    return coordinate;
}

@end
