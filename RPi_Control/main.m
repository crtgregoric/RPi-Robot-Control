//
//  main.m
//  RPi_Control
//
//  Created by Crt Gregoric on 26. 10. 14.
//  Copyright (c) 2014 crtgregoric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include "gst_ios_init.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        gst_ios_init();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
