//
//  CR_NativeLoaderDispatchChecker.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeLoader.h"
@class XCTestExpectation;

NS_ASSUME_NONNULL_BEGIN

@interface CR_NativeLoaderDispatchChecker : NSObject <CRNativeLoaderDelegate>

@property (strong, nonatomic) XCTestExpectation *didReceiveOnMainQueue;
@property (strong, nonatomic) XCTestExpectation *didFailOnMainQueue;
@property (strong, nonatomic) XCTestExpectation *didDetectImpression;
@property (strong, nonatomic) XCTestExpectation *didDetectClick;
@property (strong, nonatomic) XCTestExpectation *willLeaveApplicationForNativeAd;

@end

NS_ASSUME_NONNULL_END
