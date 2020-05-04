//
//  CR_BidRequestSerializer.h
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CR_CdbRequest;
@class CR_Config;
@class CR_DataProtectionConsent;
@class CR_DeviceInfo;
@class CR_GdprSerializer;

// This class is sematically incoherent with CR_CdbRequest.
// TODO: Refine the design and the naming of CR_CdbRequest & CR_BidRequestSerializer.
@interface CR_BidRequestSerializer : NSObject

- (instancetype)init;
- (instancetype)initWithGdprSerializer:(CR_GdprSerializer *)gdprSerializer NS_DESIGNATED_INITIALIZER;

- (NSURL *)urlWithConfig:(CR_Config *)config;
- (NSDictionary *)bodyWithCdbRequest:(CR_CdbRequest *)cdbRequest
                             consent:(CR_DataProtectionConsent *)consent
                              config:(CR_Config *)config
                          deviceInfo:(CR_DeviceInfo *)deviceInfo;

#pragma mark - Private but unit-tested (To be refactored)

- (NSArray *)slotsWithCdbRequest:(CR_CdbRequest *)cdbRequest;

@end

NS_ASSUME_NONNULL_END
