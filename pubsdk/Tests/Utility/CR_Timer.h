//
//  CRTimer.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CR_Timer : NSObject

@property (nonatomic, assign, readonly, getter=isValid) BOOL valid;

+ (CR_Timer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                               repeats:(BOOL)repeats
                                 block:(void (^)(NSTimer *timer))block;

@end

NS_ASSUME_NONNULL_END
