//
//  VideoFeedView.m
//  RPi_Control
//
//  Created by Crt Gregoric on 10. 12. 14.
//  Copyright (c) 2014 akro-in. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "VideoFeedView.h"

@implementation VideoFeedView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

@end
