//
//  StreamHelper.h
//  RPi_Control
//
//  Created by Crt Gregoric on 10. 12. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StreamHelper : NSObject

- (instancetype)initWithVideoFeedView:(UIView *)videoFeedView;

- (void)stop;

@end
