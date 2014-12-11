//
//  MathHelpers.h
//  RPi_Control
//
//  Created by Crt Gregoric on 27. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MathHelpers : NSObject

+ (BOOL)circleWithCenter:(CGPoint)center andRadius:(CGFloat)radius containsPoint:(CGPoint)point;
+ (CGPoint)coordinatesForPoint:(CGPoint)point onCircleWithCenter:(CGPoint)center andRadius:(CGFloat)radius;
+ (CGFloat)angleForPoint:(CGPoint)point onCircleWithCenter:(CGPoint)center andRadius:(CGFloat)radius;

+ (BOOL)rect:(CGRect)rect containsPoint:(CGPoint)point;

@end
