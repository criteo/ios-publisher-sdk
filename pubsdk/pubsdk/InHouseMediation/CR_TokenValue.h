//
//  CR_TokenValue.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_TokenValue : NSObject

@property (readonly, nonatomic) NSString *displayUrl;
@property (readonly, nonatomic) NSDate *insertTime;
@property (readonly, nonatomic) NSTimeInterval ttl;
@property (readonly, nonatomic) CRAdUnit *adUnit;

- (instancetype)initWithDisplayURL:(NSString *)displayURL
                        insertTime:(NSDate *)timeStamp
                               ttl:(NSTimeInterval)ttl
                            adUnit:(CRAdUnit *)adUnit;

- (BOOL)isExpired;

@end

NS_ASSUME_NONNULL_END
