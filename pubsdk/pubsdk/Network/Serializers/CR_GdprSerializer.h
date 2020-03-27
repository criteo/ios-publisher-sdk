//
//  CR_GdprSerializer.h
//  pubsdk
//
//  Created by Romain Lofaso on 3/26/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CR_Gdpr;

@interface CR_GdprSerializer : NSObject

- (nullable NSDictionary<NSString *, NSObject *> *)dictionaryForGdpr:(CR_Gdpr *)gdpr;

@end

NS_ASSUME_NONNULL_END
