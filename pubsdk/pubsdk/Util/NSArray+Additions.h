//
//  NSArray+Additions.h
//  pubsdk
//
//  Created by Richard Clark on 9/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef NSArray_Additions_h
#define NSArray_Additions_h

#import <Foundation/Foundation.h>

typedef NSArray<NSString *> StringArray;
typedef NSMutableArray<NSString *> MutableStringArray;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Criteo)

- (NSArray *)splitIntoChunks:(NSUInteger)chunkSize;

@end

NS_ASSUME_NONNULL_END

#endif /* NSArray_Additions_h */
