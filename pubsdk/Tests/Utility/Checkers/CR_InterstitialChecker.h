//
//  CR_InterstitialChecker.h
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XCTestExpectation;
@class Criteo;
@class CRInterstitial;
@class CRInterstitialAdUnit;

@interface CR_InterstitialChecker : NSObject

@property (strong, nonatomic, readonly) CRInterstitial *intertitial;

@property (strong, nonatomic, readonly) XCTestExpectation *receiveAdExpectation;
@property (strong, nonatomic, readonly) XCTestExpectation *failToReceiveAdExpectation;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit
                        criteo:(Criteo *)criteo NS_DESIGNATED_INITIALIZER;

- (void)resetExpectations;

@end

NS_ASSUME_NONNULL_END
