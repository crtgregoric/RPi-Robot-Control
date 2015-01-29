//
//  ControlButton.h
//  RPi_Control
//
//  Created by Crt Gregoric on 29. 01. 15.
//  Copyright (c) 2015 akro-in. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface ControlButton : UIButton

@property (nonatomic) IBInspectable CGFloat shapeBorderWidth;
@property (nonatomic, strong) IBInspectable UIColor *shapeBorderColor;
@property (nonatomic, strong) IBInspectable UIColor *shapeBackgroundColor;
@property (nonatomic) IBInspectable CGFloat shapeRadius;

@end
