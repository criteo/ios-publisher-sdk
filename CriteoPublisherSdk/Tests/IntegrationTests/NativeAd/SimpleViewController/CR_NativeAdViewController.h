//
//  CR_NativeAdViewController.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>
#import "CRNativeLoader.h"

NS_ASSUME_NONNULL_BEGIN

@class Criteo;
@class CRNativeAdUnit;
@class CR_SafeAreaView;
@class CR_CustomNativeAdView;

@interface CR_NativeAdViewController : UIViewController <CRNativeLoaderDelegate>

+ (instancetype)nativeAdViewControllerWithCriteo:(Criteo *)criteo;

@property(assign, nonatomic, getter=isAdViewInSafeArea)
    BOOL adViewInSafeArea API_AVAILABLE(ios(11.0));  // Default YES

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CRNativeAdUnit *adUnit;
@property(strong, nonatomic, readonly) CRNativeLoader *adLoader;
@property(strong, nonatomic, readonly) CR_CustomNativeAdView *adView;

#pragma mark Delegate counters

@property(assign, nonatomic, readonly) NSUInteger adLoadedCount;
@property(assign, nonatomic, readonly) NSUInteger detectImpressionCount;
@property(assign, nonatomic, readonly) NSUInteger detectClickCount;
@property(assign, nonatomic, readonly) NSUInteger leaveAppCount;

@end

NS_ASSUME_NONNULL_END
