//
//  NSDictionary+Criteo.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef NSDictionary_Criteo_h
#define NSDictionary_Criteo_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Criteo)

- (NSDictionary *)dictionaryWithNewValue:(nullable id)value forKey:(id)key;
- (nullable NSDictionary *)dictionaryWithNewValue:(nullable id)value forKeys:(NSArray *)keys;

@end

NS_ASSUME_NONNULL_END

#endif /* NSArray_Criteo_h */
