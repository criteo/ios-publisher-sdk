//
//  CR_CdbRequest.h
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 25/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_CacheAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_CdbRequest : NSObject

@property (strong, nonatomic, readonly) CR_CacheAdUnitArray *adUnits;

@property (strong, nonatomic, readonly) NSArray<NSString *> *impressionIds;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithAdUnits:(CR_CacheAdUnitArray *)adUnits NS_DESIGNATED_INITIALIZER;

-(NSString *)impressionIdForAdUnit:(CR_CacheAdUnit *)adUnit;

@end

NS_ASSUME_NONNULL_END
