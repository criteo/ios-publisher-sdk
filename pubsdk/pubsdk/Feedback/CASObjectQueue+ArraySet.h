//
//  CASObjectQueue+ArraySet.h
//  pubsdk
//
//  Created by Romain Lofaso on 4/3/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CASObjectQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASObjectQueue (ArraySet)

/**
 *  Adds an element to the end of the queue or assert if the object already exists.
 */
- (void)addSafely:(id)data;
/**
 * Return YES if the queue contains the given element.
 */
- (BOOL)contains:(id)data;
/**
 * Return all the queued elements as an array.
 */
- (NSArray *)all;

@end

NS_ASSUME_NONNULL_END
