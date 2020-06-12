//
//  CRMediaContent.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A media content is a Native Ad sub-element that can be loaded asynchronously.
 *
 * It represents media for native product image/video or advertiser logo.
 */
@interface CRMediaContent : NSObject

@property (copy, nonatomic, readonly, nullable) NSURL *url;
@property (assign, nonatomic, readonly) CGSize imageSize;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
