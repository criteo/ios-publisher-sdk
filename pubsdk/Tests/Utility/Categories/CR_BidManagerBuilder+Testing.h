//
//  CR_BidManagerBuilder+Testing.h
//  pubsdk
//
//  Created by Romain Lofaso on 3/24/20.
//  Copyright © 2020 Criteo. All rights reserved.
//


#import "CR_BidManagerBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_BidManagerBuilder (Testing)

+ (instancetype)testing_bidManagerWithNetworkCaptor;

@end

NS_ASSUME_NONNULL_END
