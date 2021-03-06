//
//  ControlView.h
//  RPi_Control
//
//  Created by Crt Gregoric on 27. 10. 14.
//  Copyright (c) 2014 crtgregoric. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ControlViewType) {
    ControlViewTypeRobotPosition,
    ControlViewTypeCameraTilt,
    ControlViewTypeLedBrightness
};

@class ControlView;

@protocol ControlViewDelegate <NSObject>

- (void)controlView:(ControlView *)controlView isChangingPositionTo:(CGPoint)position;

@optional
- (void)controlViewWillBeginChangingPosition:(ControlView *)contrlView;
- (void)controlViewDidEndChangigPosition:(ControlView *)controlView;

@end

IB_DESIGNABLE
@interface ControlView : UIControl

@property (nonatomic, weak) id <ControlViewDelegate> delegate;

@property (nonatomic) ControlViewType type;
@property (nonatomic, readonly) NSString *typeString;
@property (nonatomic) BOOL visible;

@property (nonatomic) IBInspectable CGFloat shapeBorderWidth;
@property (nonatomic, strong) IBInspectable UIColor *shapeBorderColor;
@property (nonatomic, strong) IBInspectable UIColor *shapeBackgroundColor;
@property (nonatomic) IBInspectable CGFloat shapeRadius;

@property (nonatomic) IBInspectable CGFloat circleRadius;
@property (nonatomic, strong) IBInspectable UIColor *circleColor;

- (void)updateCircleViewPosition:(BOOL)update animated:(BOOL)animated;

@end
