//
//  CRNativeAd.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

@import Foundation;

@class CRMediaContent;

NS_ASSUME_NONNULL_BEGIN

/**
 Model gathering the assets of an Advance Native Ad.
 */
@interface CRNativeAd : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, copy, readonly, nullable) NSString *body;
@property (nonatomic, copy, readonly, nullable) NSString *price;
@property (nonatomic, copy, readonly, nullable) NSString *callToAction;
@property (nonatomic, copy, readonly) CRMediaContent *productMedia;
@property (nonatomic, copy, readonly, nullable) NSString *advertiserDescription;
@property (nonatomic, copy, readonly) NSString *advertiserDomain;
@property (nonatomic, copy, readonly, nullable) CRMediaContent *advertiserLogoMedia;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
