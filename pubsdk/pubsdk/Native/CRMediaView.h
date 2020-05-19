//
//  CRMediaView.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class CRMediaContent;

@interface CRMediaView : UIView

/**
 * Placeholder to display while the media content is loading or in case of error.
 */
@property (strong, nonatomic, nullable) UIImage *placeholder;

/**
 * New media content to load in this view.
 */
@property (copy, nonatomic, nullable) CRMediaContent *mediaContent;

@end