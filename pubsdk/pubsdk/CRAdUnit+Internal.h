//
//  CRAdUnit+Internal.h
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 5/31/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRAdUnit_Internal_h
#define CRAdUnit_Internal_h

// TODO: Make sure we only pass valid Enum values when initializing
typedef NS_ENUM(NSInteger, CRAdUnitType) {
    CRAdUnitTypeInterstitial,
    CRAdUnitTypeBanner
};

NS_ASSUME_NONNULL_BEGIN

@interface CRAdUnit ()

@property (nonatomic, readonly) CRAdUnitType adUnitType;
- (instancetype) initWithAdUnitId:(NSString *)adUnitId
                       adUnitType:(CRAdUnitType)adUnitType;

@end

#endif /* CRAdUnit_Internal_h */

NS_ASSUME_NONNULL_END
