//
//  CRMediaView.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class CRMediaContent;

/**
 * A view that can hold and display a CRMediaContent.
 *
 * The CRMediaView takes care of loading the necessary ressources if needed.
 */
@interface CRMediaView : UIView

/**
 * Placeholder to display while the media content is loading or in case of error.
 */
@property(strong, nonatomic, nullable) UIImage *placeholder;

/**
 * New media content to load in this view.
 */
@property(strong, nonatomic, nullable) CRMediaContent *mediaContent;

@end
