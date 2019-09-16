//
//  NSDictionary+Criteo.h
//  pubsdk
//
//  Created by Richard Clark on 9/14/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef NSDictionary_Criteo_h
#define NSDictionary_Criteo_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Criteo)

- (NSDictionary *)dictionaryWithNewValue:(id _Nullable)value forKey:(id)key;

@end

NS_ASSUME_NONNULL_END

#endif /* NSArray_Criteo_h */
