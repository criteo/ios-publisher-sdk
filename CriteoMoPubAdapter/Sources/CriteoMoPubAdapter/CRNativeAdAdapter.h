//
//  CRNativeAdAdapter.h
//  CriteoMoPubAdapter
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

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

@class CRNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface CRNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property(nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;
@property(strong, nonatomic, readonly) CRNativeAd *nativeAd;

- (instancetype)initWithNativeAd:(CRNativeAd *)nativeAd;

- (void)nativeAdWillLogImpression;
- (void)nativeAdDidClick;
- (void)nativeAdWillLeaveApplication;

@end

NS_ASSUME_NONNULL_END
