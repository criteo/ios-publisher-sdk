//
//  CR_NetworkManagerMock.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const CR_NetworkManagerMockDefaultPostJsonResponse;

@interface CR_NetworkManagerMock : CR_NetworkManager

/** Default YES */
@property (nonatomic, assign, getter=isRespondingToPost) BOOL respondingToPost;
@property (nonatomic, strong, nullable) NSPredicate *postFilterUrl;
@property (nonatomic, strong, nullable) NSData *postResponseData;
@property (nonatomic, strong, nullable) NSError *postResponseError;
@property (nonatomic, strong, nullable) NSDictionary *lastPostBody;
@property (nonatomic, assign, readonly) NSUInteger numberOfPostCall;

@property (nonatomic, assign, getter=isRespondingToGet) BOOL respondingToGet;
@property (nonatomic, strong, nullable) NSData *getResponseData;
@property (nonatomic, strong, nullable) NSError *getResponseError;
@property (nonatomic, strong, nullable) NSURL *lastGetUrl;
@property (nonatomic, assign, readonly) NSUInteger numberOfGetCall;

- (instancetype)init NS_AVAILABLE_IOS(5_0);

@end

NS_ASSUME_NONNULL_END
