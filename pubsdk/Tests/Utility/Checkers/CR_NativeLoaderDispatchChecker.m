//
//  CR_NativeLoaderDispatchChecker.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_NativeLoaderDispatchChecker.h"
#import "CRNativeLoader+Internal.h"

@implementation CR_NativeLoaderDispatchChecker

- (instancetype)init {
    self = [super init];
    if (self) {
        _didFailOnMainQueue = [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
        _didReceiveOnMainQueue = [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
        _didDetectImpression = [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
        _didDetectClick = [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
        _willLeaveApplicationForNativeAd = [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
    }
    return self;
}

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
    if (@available(iOS 10.0, *)) {
        dispatch_assert_queue(dispatch_get_main_queue());
    }
    [self.didReceiveOnMainQueue fulfill];
}

- (void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error {
    if (@available(iOS 10.0, *)) {
        dispatch_assert_queue(dispatch_get_main_queue());
    }
    [self.didFailOnMainQueue fulfill];
}

- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader {
    if (@available(iOS 10.0, *)) {
        dispatch_assert_queue(dispatch_get_main_queue());
    }
    [self.didDetectImpression fulfill];
}

- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader {
    if (@available(iOS 10.0, *)) {
        dispatch_assert_queue(dispatch_get_main_queue());
    }
    [self.didDetectClick fulfill];
}

- (void)nativeLoaderWillLeaveApplication:(CRNativeLoader *)loader {
    if (@available(iOS 10.0, *)) {
        dispatch_assert_queue(dispatch_get_main_queue());
    }
    [self.willLeaveApplicationForNativeAd fulfill];
}

@end
