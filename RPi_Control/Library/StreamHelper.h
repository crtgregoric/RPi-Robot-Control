//
//  StreamHelper.h
//  RPi_Control
//
//  Created by Crt Gregoric on 10. 12. 14.
//  Copyright (c) 2014 crtgregoric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class StreamHelper;

@protocol StreamHelperDelegate <NSObject>

@optional
- (void)streamerHelperDidStartDisplayingVideo:(StreamHelper *)streamerHelper;

@end

@interface StreamHelper : NSObject

- (instancetype)initWithVideoFeedView:(UIView *)videoFeedView delegate:(id <StreamHelperDelegate>)delegate;

- (void)stop;

@end
