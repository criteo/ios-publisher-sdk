//
//  CR_NetworkWaiter.h
//  pubsdkTests
//
//  Created by Romain Lofaso on 11/27/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const NSTimeInterval CR_NetworkWaiterDefaultTimeout;

@class CR_NetworkCaptor;
@class CR_HttpContent;

typedef BOOL (^CR_HTTPResponseTester)(CR_HttpContent *httpContent);

@interface CR_NetworkWaiter : NSObject

@property (nonatomic, assign, readonly) BOOL finished;
@property (nonatomic, weak, readonly) CR_NetworkCaptor *networkCaptor;

- (instancetype)initWithNetworkCaptor:(CR_NetworkCaptor *)networkCaptor;

- (BOOL)waitWithResponseTester:(CR_HTTPResponseTester)tester;
- (BOOL)waitWithTimeout:(NSTimeInterval)timeout responseTester:(CR_HTTPResponseTester)tester;

@end

NS_ASSUME_NONNULL_END
