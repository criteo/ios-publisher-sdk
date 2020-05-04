//
//  CR_NetworkWaiter.h
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const NSTimeInterval CR_NetworkWaiterDefaultTimeout;

@class CR_NetworkCaptor;
@class CR_HttpContent;

typedef BOOL (^CR_HTTPResponseTester)(CR_HttpContent *httpContent);

@interface CR_NetworkWaiter : NSObject

@property (nonatomic, weak, readonly) CR_NetworkCaptor *networkCaptor;
@property (nonatomic, strong, readonly) NSArray<CR_HTTPResponseTester> *testers;
@property (nonatomic, assign) BOOL finishedRequestsIncluded;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNetworkCaptor:(CR_NetworkCaptor *)networkCaptor
                              testers:(NSArray<CR_HTTPResponseTester> *)testers NS_DESIGNATED_INITIALIZER;

- (BOOL)wait;
- (BOOL)waitWithTimeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
