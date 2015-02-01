//
//  Globals.h
//  RPi_Control
//
//  Created by Crt Gregoric on 3. 11. 14.
//  Copyright (c) 2014 crtgregoric. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define MAC_SERVER

#ifdef MAC_SERVER
static const NSString *kHostName = @"cromartie.local";
#else
static const NSString *kHostName = @"rpi.local";
#endif
static const NSInteger kPortNumber = 6000;
static const NSInteger kStreamPortNumber = 5000;
