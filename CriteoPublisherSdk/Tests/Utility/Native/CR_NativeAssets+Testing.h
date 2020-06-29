//
//  CR_TestNativeAssets.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_NativeAssets.h"

@interface CR_NativeAssets (Testing)

+ (CR_NativeAssets *)nativeAssetsFromCdb;

@end