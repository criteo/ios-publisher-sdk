//
// Copyright (c) 2020 Criteo. All rights reserved.
//

#ifndef CR_FeedbackProxy_H
#define CR_FeedbackProxy_H

#import <Foundation/Foundation.h>
#import "CR_FeedbackController.h"

@class CR_Config;

@interface CR_FeedbackFeatureGuard : NSObject <CR_FeedbackDelegate>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithController:(CR_FeedbackController *)controller
                            config:(CR_Config *)config
NS_DESIGNATED_INITIALIZER;

@end

#endif /* CR_FeedbackProxy_H */
