//
//  CR_FeedbacksSerializer.h
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 26/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_FeedbackMessage;
@class CR_Config;

NS_ASSUME_NONNULL_BEGIN

@interface CR_FeedbacksSerializer : NSObject

- (NSDictionary *)postBodyForCsm:(NSArray<CR_FeedbackMessage *> *)messages
                          config:(CR_Config *)config;

@end

NS_ASSUME_NONNULL_END
