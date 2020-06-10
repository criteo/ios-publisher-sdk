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
 * Model gathering the assets of an Advance Native Ad.
 */
@interface CRNativeAd : NSObject

/** The headline (like the name of the advertised product). */
@property (nonatomic, copy, readonly, nullable) NSString *title;
/** The description of the product. */
@property (nonatomic, copy, readonly, nullable) NSString *body;
/** The price of the product. */
@property (nonatomic, copy, readonly, nullable) NSString *price;
/** Text that encourages user to take some action with the ad. For example "Buy" or "Install". */
@property (nonatomic, copy, readonly, nullable) NSString *callToAction;
/** The image that represents the product. */
@property (nonatomic, copy, readonly) CRMediaContent *productMedia;
/** The description of the company that advertises the product. */
@property (nonatomic, copy, readonly, nullable) NSString *advertiserDescription;
/** The domain name of the company that advertises the product. */
@property (nonatomic, copy, readonly) NSString *advertiserDomain;
/** The logo of the company that advertises the product. */
@property (nonatomic, copy, readonly, nullable) CRMediaContent *advertiserLogoMedia;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
