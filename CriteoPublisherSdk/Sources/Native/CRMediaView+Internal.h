//
//  CRMediaView+Internal.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMediaView.h"

@class UIImageView;

@interface CRMediaView ()

@property(strong, nonatomic, nullable) UIImageView *imageView;
@property(strong, nonatomic, nullable) NSURL *imageUrl;

@end