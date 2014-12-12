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
    
    if (coordinate.x >= 0 && coordinate.y >= 0) {
        // I. quadrant
        angle = angle - M_PI_4;
        coordinate.x = distance;
        coordinate.y = distance * (angle / M_PI_4);
        
    } else if (coordinate.x <= 0 && coordinate.y >= 0) {
        // II. quadrant
        angle = angle - (3 * M_PI_4);
        coordinate.x = distance * (-angle / M_PI_4);
        coordinate.y = distance;
        
    } else if (coordinate.x <= 0 && coordinate.y <= 0) {
        // III. quadrant
        angle = angle + (3 * M_PI_4);
        coordinate.x = -distance;
        coordinate.y = distance * (-angle / M_PI_4);

    } else {
        // IV. quadrant
        angle = angle + M_PI_4;
        coordinate.x = distance * (angle / M_PI_4);
        coordinate.y = -distance;

    }
    
    return coordinate;
}

@end
