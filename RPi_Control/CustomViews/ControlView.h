//
//  ControlView.h
//  RPi_Control
//
//  Created by Crt Gregoric on 27. 10. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ControlViewPosition) {
    ControlViewPositionRight,
    ControlViewPositionLeft
};

@class ControlView;

@protocol ControlViewDelegate <NSObject>

@optional
- (void)controlView:(ControlView *)controlView positionDidChange:(CGVector)position;

@end

IB_DESIGNABLE
@interface ControlView : UIView

@property (nonatomic, weak) id <ControlViewDelegate> delegate;

@property (nonatomic) ControlViewPosition position;

@property (nonatomic) IBInspectable CGFloat shapeBorderWidth;
@property (nonatomic, strong) IBInspectable UIColor *shapeBorderColor;
@property (nonatomic, strong) IBInspectable UIColor *shapeBackgroundColor;

@property (nonatomic) IBInspectable CGFloat circleRadius;
@property (nonatomic, strong) IBInspectable UIColor *circleColor;

@end
