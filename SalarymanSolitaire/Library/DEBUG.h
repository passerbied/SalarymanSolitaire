//
//  DEBUG.h
//  SalarymanSolitaire
//
//  Created by i-chou on 7/12/14.
//  Copyright (c) 2014 i-chou All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NDEBUG

#define DLOG(format, ...)           \
        NSLog(@"\n%s:\n%@",             \
        __PRETTY_FUNCTION__,        \
        [NSString stringWithFormat:format, ## __VA_ARGS__]);

#define DOBJ(obj)  DLOG(@"%s: %@", #obj, [(obj) description]);

#define MARK    NSLog(@"\nMARK: %s, %d", __PRETTY_FUNCTION__, __LINE__);

#define START_TIMER                 \
        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#define END_TIMER(msg)              \
        DLOG([NSString stringWithFormat:"%@ Time = %f", msg, \
            [NSDate timeIntervalSinceReferenceDate]-start]);

#else

#define DLOG
#define DOBJ
#define MARK
#define START_TIMER
#define END_TIMER

#endif

UIColor *
DCOLOR(void);

