//
//  DifferentialSteeringHelper.h
//  RPi_Control
//
//  Created by Crt Gregoric on 12. 12. 14.
//  Copyright (c) 2014 crtgregoric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DifferentialSteeringHelper : NSObject

+ (CGPoint)differentialMotorSpeedForCoordinate:(CGPoint)coordinate inCircleWithRadius:(CGFloat)radius;

@end
