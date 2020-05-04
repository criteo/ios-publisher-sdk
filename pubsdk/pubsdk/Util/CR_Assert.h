//
//  CR_Assert.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_Assert_h
#define CR_Assert_h

#import "Logging.h"

/** Handle the Release mode that remove the NSAsserts */
#define CR_Assert(condition, desc, ...) \
do { \
    NSAssert(condition, desc, ##__VA_ARGS__); \
    if (!condition) { \
        CLog(desc, ##__VA_ARGS__); \
    } \
} while(0)

#endif /* CR_Assert_h */
