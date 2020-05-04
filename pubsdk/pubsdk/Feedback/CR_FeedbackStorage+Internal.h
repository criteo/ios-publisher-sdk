//
//  CR_FeedbackStorage.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef CR_FeedbackStorage_Internal_h
#define CR_FeedbackStorage_Internal_h

#import "CR_FeedbackStorage.h"

@interface CR_FeedbackStorage ()

- (NSString *)getOrCreateFilenameForAdUnit:(CR_CacheAdUnit *)adUnit;

- (CR_FeedbackMessage *)readOrCreateFeedbackMessageByFilename:(NSString *)filename;

@end

#endif /* CR_FeedbackStorage_Internal_h */
