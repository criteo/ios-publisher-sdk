//
//  NSUserDefaults+CRPrivateKeysAndUtils.h
//  pubsdk
//
//  Created by Romain Lofaso on 10/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const NSUserDefaultsKillSwitchKey;

@interface NSUserDefaults (CRPrivateKeysAndUtils)

- (BOOL)containsKey: (NSString *)key;

@end

NS_ASSUME_NONNULL_END
