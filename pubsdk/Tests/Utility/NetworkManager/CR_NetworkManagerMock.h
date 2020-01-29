//
//  CR_NetworkManagerMock.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/11/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const CR_NetworkManagerMockDefaultPostJsonResponse;

@interface CR_NetworkManagerMock : CR_NetworkManager

/** Default YES */
@property (nonatomic, assign, getter=isRespondingToPost) BOOL respondingToPost;
@property (nonatomic, strong, nullable) NSData *postResponseData;
@property (nonatomic, strong, nullable) NSError *postReponseError;
@property (nonatomic, strong, nullable) NSDictionary *lastPostBody;
@property (nonatomic, assign, readonly) NSUInteger numberOfPostCall;

- (instancetype)init NS_AVAILABLE_IOS(5_0);

@end

NS_ASSUME_NONNULL_END
