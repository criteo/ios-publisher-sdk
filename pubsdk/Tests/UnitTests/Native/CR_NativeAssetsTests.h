//
//  CR_NativeAssetsTest.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

@class CR_NativeAssets;

@interface CR_NativeAssetsTests : XCTestCase
+ (CR_NativeAssets *)loadNativeAssets:(NSString *)fileName;
@end
