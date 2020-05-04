//
//  CRBannerViewDelegateMock.h
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

@import Foundation;
@import XCTest;
#import "CRBannerViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRBannerViewDelegateMock : NSObject <CRBannerViewDelegate>

@property (nonatomic, strong) NSError *expectedError;

@property (nonatomic, strong, readonly) XCTestExpectation *didFailToReceiveAdWithErrorExpectation;
@property (nonatomic, strong, readonly) XCTestExpectation *didReceiveAdExpectation;
@property (nonatomic, strong, readonly) XCTestExpectation *willLeaveApplicationExpectation;
@property (nonatomic, strong, readonly) XCTestExpectation *wasClickedExpectation;
@property (nonatomic, strong, readonly) NSArray<XCTestExpectation *> *allExpectations;

- (void)invertAllExpectations;

@end

NS_ASSUME_NONNULL_END
