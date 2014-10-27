//
//  ControlView.h
//  RPi_Control
//
//  Created by Crt Gregoric on 27. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ControlViewPosition) {
    ControlViewPositionLeft,
    ControlViewPositionRight
};

IB_DESIGNABLE
@interface ControlView : UIView

@property (nonatomic) ControlViewPosition position;

@property (nonatomic) IBInspectable CGFloat shapeBorderWidth;
@property (nonatomic, strong) IBInspectable UIColor *shapeBorderColor;
@property (nonatomic, strong) IBInspectable UIColor *shapeBackgroundColor;

@end
