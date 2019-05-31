//
//  CRAdUnit.h
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 5/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRAdUnit : NSObject

@property (readonly, nonatomic) NSString *adUnitId;

- (instancetype) init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
