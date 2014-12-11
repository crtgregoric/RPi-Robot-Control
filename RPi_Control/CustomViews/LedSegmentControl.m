//
//  LedSegmentControl.m
//  RPi_Control
//
//  Created by Crt Gregoric on 11. 12. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LedSegmentControl.h"

@implementation LedSegmentControl

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupUI];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (instancetype)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    self.tintColor = [UIColor colorWithWhite:0.50 alpha:0.25];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 4.0f;
    
    [self setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } forState:UIControlStateNormal];
    [self setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor clearColor] } forState:UIControlStateSelected];
    
    UIImage *blackDivider = [self imageWithColor:[UIColor blackColor]];
    [self setDividerImage:blackDivider forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setDividerImage:blackDivider forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setDividerImage:blackDivider forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
